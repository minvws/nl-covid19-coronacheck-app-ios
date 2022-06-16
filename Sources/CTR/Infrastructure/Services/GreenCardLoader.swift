/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol GreenCardLoading {
	func signTheEventsIntoGreenCardsAndCredentials(
		responseEvaluator: ((RemoteGreenCards.Response) -> Bool)?,
		completion: @escaping (Result<RemoteGreenCards.Response, Swift.Error>) -> Void)
}

class GreenCardLoader: GreenCardLoading {

	enum Error: Swift.Error, Equatable, LocalizedError {
		case noSignedEvents
		case didNotEvaluate

		case preparingIssue(ServerError)
		case failedToParsePrepareIssue
		case failedToGenerateCommitmentMessage
		case failedToGenerateDomesticSecretKey
		case credentials(ServerError)
		case failedToSaveGreenCards

		var errorDescription: String? {
			switch self {
				case .credentials(.error(_, _, let networkError)):
					return "credentials/" + networkError.rawValue
				case .credentials(.provider(_, _, _, let networkError)):
					return "credentials/provider/" + networkError.rawValue
				case .preparingIssue(.error(_, _, let networkError)):
					return "preparingIssue/" + networkError.rawValue
				case .preparingIssue(.provider(_, _, _, let networkError)):
					return "preparingIssue/provider/" + networkError.rawValue
				case .noSignedEvents:
					return "noSignedEvents"
				case .didNotEvaluate:
					return "didNotEvaluate"
				case .failedToParsePrepareIssue:
					return "failedToParsePrepareIssue"
				case .failedToGenerateCommitmentMessage:
					return "failedToGenerateCommitmentMessage"
				case .failedToGenerateDomesticSecretKey:
					return "failedToGenerateDomesticSecretKey"
				case .failedToSaveGreenCards:
					return "failedToSaveGreenCards"
			}
		}
	}

	private let now: () -> Date
	private let networkManager: NetworkManaging
	private let cryptoManager: CryptoManaging
	private let walletManager: WalletManaging
	private let remoteConfigManager: RemoteConfigManaging
	private let userSettings: UserSettingsProtocol
	private let secureUserSettings: SecureUserSettingsProtocol
	private let logHandler: Logging?
	
	required init(
		now: @escaping () -> Date,
		networkManager: NetworkManaging,
		cryptoManager: CryptoManaging,
		walletManager: WalletManaging,
		remoteConfigManager: RemoteConfigManaging,
		userSettings: UserSettingsProtocol,
		secureUserSettings: SecureUserSettingsProtocol,
		logHandler: Logging? = nil
	) {

		self.now = now
		self.networkManager = networkManager
		self.cryptoManager = cryptoManager
		self.walletManager = walletManager
		self.remoteConfigManager = remoteConfigManager
		self.userSettings = userSettings
		self.secureUserSettings = secureUserSettings
		self.logHandler = logHandler
	}

	func signTheEventsIntoGreenCardsAndCredentials(
		responseEvaluator: ((RemoteGreenCards.Response) -> Bool)?,
		completion: @escaping (Result<RemoteGreenCards.Response, Swift.Error>) -> Void) {
		
		guard let newSecretKey = self.cryptoManager.generateSecretKey() else {
			self.logHandler?.logError("GreenCardLoader - can't create new secret key")
			completion(.failure(Error.failedToGenerateDomesticSecretKey))
			return
		}

		networkManager.prepareIssue { [weak self] (prepareIssueResult: Result<PrepareIssueEnvelope, ServerError>) in
			switch prepareIssueResult {
				case .failure(let serverError):
					self?.logHandler?.logError("GreenCardLoader - prepareIssue error: \(serverError)")
					completion(.failure(Error.preparingIssue(serverError)))
					
				case .success(let prepareIssueEnvelope):
					guard let nonce = prepareIssueEnvelope.prepareIssueMessage.base64Decoded() else {
						self?.logHandler?.logError("GreenCardLoader - can't parse the nonce / prepareIssueMessage")
						completion(.failure(Error.failedToParsePrepareIssue))
						return
					}
					self?.fetchGreenCards(
						secretKey: newSecretKey,
						nonce: nonce,
						stoken: prepareIssueEnvelope.stoken) { response in
						switch response {
							case .failure(let error):
								completion(.failure(error))
								
							case .success(let greenCardResponse):
								if let evaluator = responseEvaluator, !evaluator(greenCardResponse) {
									completion(.failure(Error.didNotEvaluate))
									return
								}
								
								self?.storeGreenCards(secretKey: newSecretKey, response: greenCardResponse) { greenCardsSaved in
									guard greenCardsSaved else {
										self?.logHandler?.logError("GreenCardLoader - failed to save greenCards")
										completion(.failure(Error.failedToSaveGreenCards))
										return
									}
									completion(.success(greenCardResponse))
								}
						}
					}
			}
		}
	}

	private func fetchGreenCards(
		secretKey: Data,
		nonce: String,
		stoken: String,
		onCompletion: @escaping (Result<RemoteGreenCards.Response, Swift.Error>) -> Void) {

		let signedEvents = walletManager.fetchSignedEvents()

		guard !signedEvents.isEmpty else {
			onCompletion(.failure(Error.noSignedEvents))
			return
		}

		guard let issueCommitmentMessage = cryptoManager.generateCommitmentMessage(nonce: nonce, holderSecretKey: secretKey),
			  let issueCommitmentMessageData = issueCommitmentMessage.data(using: .utf8) else {
			onCompletion(.failure(Error.failedToGenerateCommitmentMessage))
			return
		}

		let dictionary: [String: AnyObject] = [
			"stoken": stoken as AnyObject,
			"events": signedEvents as AnyObject,
			"issueCommitmentMessage": issueCommitmentMessageData.base64EncodedString() as AnyObject
		]
		
		self.networkManager.fetchGreencards(dictionary: dictionary) { [weak self] (result: Result<RemoteGreenCards.Response, ServerError>) in
			switch result {
				case .failure(let serverError):
					self?.logHandler?.logError("error: \(serverError)")
					onCompletion(.failure(Error.credentials(serverError)))

				case let .success(greencardResponse):
					self?.logHandler?.logVerbose("GreenCardLoader - succes: \(greencardResponse)")
					onCompletion(.success(greencardResponse))
			}
		}
	}

	// MARK: Store green cards

	private func storeGreenCards(
		secretKey: Data?,
		response: RemoteGreenCards.Response,
		onCompletion: @escaping (Bool) -> Void) {

		var success = true

		walletManager.removeExistingGreenCards()
		
		// Store the new secret key
		secureUserSettings.holderSecretKey = secretKey
		
		// Domestic
		if let domestic = response.domesticGreenCard {
			success = success && walletManager.storeDomesticGreenCard(domestic, cryptoManager: cryptoManager)
		} else {
			// Don't hold on to the key if there are no domestic greencards.
			secureUserSettings.holderSecretKey = nil
		}
		// International
		if let remoteEuGreenCards = response.euGreenCards {
			for remoteEuGreenCard in remoteEuGreenCards {
				success = success && walletManager.storeEuGreenCard(remoteEuGreenCard, cryptoManager: cryptoManager)
			}
		}
		// Expiries
		if let blobExpireDates = response.blobExpireDates {
			for expiry in blobExpireDates {
				walletManager.updateEventGroup(identifier: expiry.identifier, expiryDate: expiry.expirationDate)
			}
		}
		onCompletion(success)
	}
}

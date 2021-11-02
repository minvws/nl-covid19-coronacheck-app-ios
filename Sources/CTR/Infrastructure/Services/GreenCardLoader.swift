/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol GreenCardLoading {
	init(networkManager: NetworkManaging, cryptoManager: CryptoManaging, walletManager: WalletManaging)

	func signTheEventsIntoGreenCardsAndCredentials(
		responseEvaluator: ((RemoteGreenCards.Response) -> Bool)?,
		completion: @escaping (Result<Void, Swift.Error>) -> Void)
}

class GreenCardLoader: GreenCardLoading, Logging {

	enum Error: Swift.Error, Equatable, LocalizedError {
		case noEvents
		case didNotEvaluate

		case preparingIssue(ServerError)
		case failedToParsePrepareIssue
		case failedToGenerateCommitmentMessage
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
				case .noEvents:
					return "noEvents"
				case .didNotEvaluate:
					return "didNotEvaluate"
				case .failedToParsePrepareIssue:
					return "failedToParsePrepareIssue"
				case .failedToGenerateCommitmentMessage:
					return "failedToGenerateCommitmentMessage"
				case .failedToSaveGreenCards:
					return "failedToSaveGreenCards"
			}
		}
	}

	private let networkManager: NetworkManaging
	private let cryptoManager: CryptoManaging
	private let walletManager: WalletManaging

	required init(
		networkManager: NetworkManaging = Services.networkManager,
		cryptoManager: CryptoManaging = Services.cryptoManager,
		walletManager: WalletManaging = Services.walletManager) {

		self.networkManager = networkManager
		self.cryptoManager = cryptoManager
		self.walletManager = walletManager
	}

	func signTheEventsIntoGreenCardsAndCredentials(
		responseEvaluator: ((RemoteGreenCards.Response) -> Bool)?,
		completion: @escaping (Result<Void, Swift.Error>) -> Void) {
		
		networkManager.prepareIssue { (prepareIssueResult: Result<PrepareIssueEnvelope, ServerError>) in
			switch prepareIssueResult {
				case .failure(let serverError):
					self.logError("error: \(serverError)")
					completion(.failure(Error.preparingIssue(serverError)))

				case .success(let prepareIssueEnvelope):
					guard let nonce = prepareIssueEnvelope.prepareIssueMessage.base64Decoded() else {
						self.logError("Can't parse the nonce / prepareIssueMessage")
						completion(.failure(Error.failedToParsePrepareIssue))
						return
					}

					self.logVerbose("ok: \(prepareIssueEnvelope)")
					self.cryptoManager.setNonce(nonce)
					self.cryptoManager.setStoken(prepareIssueEnvelope.stoken)
					self.fetchGreenCards { response in
						switch response {
							case .failure(let error):
								completion(.failure(error))

							case .success(let greenCardResponse):
								if let evaluator = responseEvaluator, !evaluator(greenCardResponse) {
									completion(.failure(Error.didNotEvaluate))
									return
								}

								self.storeGreenCards(response: greenCardResponse) { greenCardsSaved in
									guard greenCardsSaved else {
										self.logError("Failed to save greenCards")
										completion(.failure(Error.failedToSaveGreenCards))
										return
									}

									// ~~ 📆 TEMPORARY - will be removed in 1 month ~~
									GreenCardLoader.temporary___updateRecoveryExtensionValidityFlags(
										userSettings: UserSettings(),
										remoteConfigManager: Services.remoteConfigManager,
										now: { Date() }
									)

									completion(.success(()))
								}
						}
					}
			}
		}
	}

	// ~~ 📆 TEMPORARY - will be removed in 1 month ~~
	// TODO: Resolve this https://prototypecoro-oqr1532.slack.com/archives/D01T6EUEBFF/p1635586594022600
	static func temporary___updateRecoveryExtensionValidityFlags(
		userSettings: UserSettingsProtocol,
		remoteConfigManager: RemoteConfigManaging,
		now: @escaping () -> Date
	) {
		guard let launchDate = remoteConfigManager.storedConfiguration.recoveryGreencardRevisedValidityLaunchDate,
			  launchDate < now()
		else { return }

		// Scenario:
		// We add new recovery events _after_ `shouldCheckRecoveryGreenCardRevisedValidity` is checked by RecoveryValidityExtensionManager
		// which means this would still be true. If that's the case, well we're adding a fresh Recovery greencard now
		// so definitely need to set it to false here to disable that whole feature.
		guard !userSettings.shouldCheckRecoveryGreenCardRevisedValidity else {
			userSettings.shouldCheckRecoveryGreenCardRevisedValidity = false // TODO: test this scenario - shouldn't it show a success banner?
			return
		}

		if userSettings.shouldShowRecoveryValidityExtensionCard {

			// Enable this card to be visible
			userSettings.hasDismissedRecoveryValidityExtensionCard = false

			userSettings.shouldShowRecoveryValidityExtensionCard = false
			userSettings.shouldShowRecoveryValidityReinstationCard = false
		} else if userSettings.shouldShowRecoveryValidityReinstationCard {

			// Enable this card to be visible
			userSettings.hasDismissedRecoveryValidityReinstationCard = false

			userSettings.shouldShowRecoveryValidityExtensionCard = false
			userSettings.shouldShowRecoveryValidityReinstationCard = false
		}
	}
	// ~~ END Temporary - will be removed in 1 month ~~

	private func fetchGreenCards(_ onCompletion: @escaping (Result<RemoteGreenCards.Response, Swift.Error>) -> Void) {

		let signedEvents = walletManager.fetchSignedEvents()

		guard !signedEvents.isEmpty else {
			onCompletion(.failure(Error.noEvents))
			return
		}

		guard let issueCommitmentMessage = cryptoManager.generateCommitmentMessage(),
			let utf8 = issueCommitmentMessage.data(using: .utf8),
			let stoken = cryptoManager.getStoken()
		else {
			onCompletion(.failure(Error.failedToGenerateCommitmentMessage))
			return
		}

		let dictionary: [String: AnyObject] = [
			"stoken": stoken as AnyObject,
			"events": signedEvents as AnyObject,
			"issueCommitmentMessage": utf8.base64EncodedString() as AnyObject
		]

		self.networkManager.fetchGreencards(dictionary: dictionary) { [weak self] (result: Result<RemoteGreenCards.Response, ServerError>) in
			switch result {
				case .failure(let serverError):
					self?.logError("error: \(serverError)")
					onCompletion(.failure(Error.credentials(serverError)))

				case let .success(greencardResponse):
					self?.logVerbose("GreenCardLoader - succes: \(greencardResponse)")
					onCompletion(.success(greencardResponse))
			}
		}
	}

	// MARK: Store green cards

	private func storeGreenCards(
		response: RemoteGreenCards.Response,
		onCompletion: @escaping (Bool) -> Void) {

		var success = true

		walletManager.removeExistingGreenCards()

		if let domestic = response.domesticGreenCard {
			success = success && walletManager.storeDomesticGreenCard(domestic, cryptoManager: cryptoManager)
		}
		if let remoteEuGreenCards = response.euGreenCards {
			for remoteEuGreenCard in remoteEuGreenCards {
				success = success && walletManager.storeEuGreenCard(remoteEuGreenCard, cryptoManager: cryptoManager)
			}
		}
		onCompletion(success)
	}
}

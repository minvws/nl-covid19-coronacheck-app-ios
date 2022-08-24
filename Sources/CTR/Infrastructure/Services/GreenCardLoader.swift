/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol GreenCardLoading {
	func signTheEventsIntoGreenCardsAndCredentials(
		eventMode: EventMode?,
		completion: @escaping (Result<RemoteGreenCards.Response, GreenCardLoader.Error>) -> Void)
}

class GreenCardLoader: GreenCardLoading {

	enum Error: Swift.Error, Equatable, LocalizedError {
		case noSignedEvents

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

	private let networkManager: NetworkManaging
	private let cryptoManager: CryptoManaging
	private let walletManager: WalletManaging
	private let secureUserSettings: SecureUserSettingsProtocol
	
	required init(
		networkManager: NetworkManaging,
		cryptoManager: CryptoManaging,
		walletManager: WalletManaging,
		secureUserSettings: SecureUserSettingsProtocol
	) {

		self.networkManager = networkManager
		self.cryptoManager = cryptoManager
		self.walletManager = walletManager
		self.secureUserSettings = secureUserSettings
	}

	func signTheEventsIntoGreenCardsAndCredentials(
		eventMode: EventMode?,
		completion: @escaping (Result<RemoteGreenCards.Response, GreenCardLoader.Error>) -> Void) {
		
		guard let newSecretKey = self.cryptoManager.generateSecretKey() else {
			logError("GreenCardLoader - can't create new secret key")
			completion(.failure(Error.failedToGenerateDomesticSecretKey))
			return
		}

		networkManager
			.prepareIssue()
			.mapError(type: ServerError.self) { Error.preparingIssue($0) }
			.then { (prepareIssueEnvelope) throws -> (String, String) in
				
				guard let nonce = prepareIssueEnvelope.prepareIssueMessage.base64Decoded() else {
					logError("GreenCardLoader - can't parse the nonce / prepareIssueMessage")
					throw Error.failedToParsePrepareIssue
				}
				
				return (nonce, prepareIssueEnvelope.stoken)
			}
			.then { [self] (nonce, stoken) throws -> Promise<RemoteGreenCards.Response> in
				
				return fetchGreenCards(eventMode: eventMode, secretKey: newSecretKey, nonce: nonce, stoken: stoken)
					.mapError(type: ServerError.self) { serverError in
						logError("GreenCardLoader - prepareIssue error: \(serverError)")
						return Error.preparingIssue(serverError)
					}
			}
			.then { [self] greenCardResponse throws in
				
				guard storeGreenCards(secretKey: newSecretKey, response: greenCardResponse) else {
					logError("GreenCardLoader - failed to save greenCards")
					throw Error.failedToSaveGreenCards
				}
				
				completion(.success(greenCardResponse))
			}
			.catch { error in
				guard let error = error as? GreenCardLoader.Error else { fatalError() } // not possible in POC.
				completion(.failure(error))
			}
	}

	private func fetchGreenCards(
		eventMode: EventMode?,
		secretKey: Data,
		nonce: String,
		stoken: String) -> Promise<RemoteGreenCards.Response> {

		let signedEvents = walletManager.fetchSignedEvents()

		guard !signedEvents.isEmpty else {
			return Promise(error: Error.noSignedEvents)
		}

		guard let issueCommitmentMessageString = cryptoManager.generateCommitmentMessage(nonce: nonce, holderSecretKey: secretKey),
			  issueCommitmentMessageString.isNotEmpty,
			  let issueCommitmentMessage = issueCommitmentMessageString.data(using: .utf8)?.base64EncodedString() else {
			
			return Promise(error: Error.failedToGenerateCommitmentMessage)
		}

		let dictionary: [String: AnyObject] = [
			"stoken": stoken as AnyObject,
			"events": signedEvents as AnyObject,
			"issueCommitmentMessage": issueCommitmentMessage as AnyObject,
			"flows": (eventMode?.asList ?? []) as AnyObject
		]
		
		return self.networkManager
			.fetchGreencards(dictionary: dictionary)
			.logVerbose("GreenCardLoader - success")
			.mapError(type: ServerError.self) { serverError in
				Error.credentials(serverError)
			}
	}

	// MARK: Store green cards

	private func storeGreenCards(secretKey: Data?, response: RemoteGreenCards.Response) -> Bool {

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
		
		return success
	}
}

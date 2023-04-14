/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import BrightFutures
import Transport
import Shared
import Persistence

public protocol GreenCardLoading {
	func signTheEventsIntoGreenCardsAndCredentials(
		eventMode: EventMode?,
		completion: @escaping (Result<RemoteGreenCards.Response, GreenCardLoader.Error>) -> Void)
}

public class GreenCardLoader: GreenCardLoading {

	public enum Error: Swift.Error, Equatable, LocalizedError {
		case noSignedEvents

		case preparingIssue(ServerError)
		case failedToParsePrepareIssue
		case failedToGenerateCommitmentMessage
		case failedToGenerateDomesticSecretKey
		case credentials(ServerError)
		case failedToSaveGreenCards

		public var errorDescription: String? {
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
	
	public required init(
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

	public func signTheEventsIntoGreenCardsAndCredentials(
		eventMode: EventMode?,
		completion: @escaping (Result<RemoteGreenCards.Response, GreenCardLoader.Error>) -> Void) {
		
		guard let newSecretKey = self.cryptoManager.generateSecretKey() else {
			logError("GreenCardLoader - can't create new secret key")
			completion(.failure(Error.failedToGenerateDomesticSecretKey))
			return
		}

		Future(resolver: networkManager.prepareIssue)
			.mapError { serverError in
				Error.preparingIssue(serverError)
			}
			.flatMap { prepareIssueEnvelope -> Future<(String, String), GreenCardLoader.Error> in

				guard let nonce = prepareIssueEnvelope.prepareIssueMessage.base64Decoded() else {
					return Future(error: Error.failedToParsePrepareIssue)
				}

				return Future(value: (nonce, prepareIssueEnvelope.stoken))
			}
			.flatMap { [self] nonce, stoken in
				fetchGreenCards(eventMode: eventMode, secretKey: newSecretKey, nonce: nonce, stoken: stoken)
			}
			.flatMap { [self] greenCardResponse in
				storeGreenCards(secretKey: newSecretKey, response: greenCardResponse)
					// .logOnError("GreenCardLoader - failed to save greenCards")
					.map { _ in greenCardResponse } // `storeGreenCards` returns no value, so make the outer return value greenCardResponse again
			}
			.onComplete { (result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>) in
				completion(result)
			}
	}

	private func fetchGreenCards(
		eventMode: EventMode?,
		secretKey: Data,
		nonce: String,
		stoken: String) -> Future<RemoteGreenCards.Response, GreenCardLoader.Error> {

		let signedEvents = walletManager.fetchSignedEvents()

		guard !signedEvents.isEmpty else {
			return Future(error: Error.noSignedEvents)
		}

		guard let issueCommitmentMessageString = cryptoManager.generateCommitmentMessage(nonce: nonce, holderSecretKey: secretKey),
			  issueCommitmentMessageString.isNotEmpty,
			  let issueCommitmentMessage = issueCommitmentMessageString.data(using: .utf8)?.base64EncodedString() else {
			
			return Future(error: Error.failedToGenerateCommitmentMessage)
		}

		let dictionary: [String: AnyObject] = [
			"stoken": stoken as AnyObject,
			"events": signedEvents as AnyObject,
			"issueCommitmentMessage": issueCommitmentMessage as AnyObject,
			"flows": (eventMode?.asList ?? []) as AnyObject
		]
			
		return Future(resolver: { completion in
				networkManager.fetchGreencards(dictionary: dictionary, completion: completion)
			})
			.mapError { serverError in
				Error.credentials(serverError)
			}
	}

	// MARK: Store green cards

	private func storeGreenCards(secretKey: Data?, response: RemoteGreenCards.Response) -> Future<Void, GreenCardLoader.Error> {

		var success = true

		walletManager.removeExistingGreenCards(secureUserSettings: secureUserSettings)
		
		// Store the new secret key
		secureUserSettings.holderSecretKey = secretKey
		
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
		
		return success ? Future(value: ()) : Future(error: .failedToSaveGreenCards)
	}
}

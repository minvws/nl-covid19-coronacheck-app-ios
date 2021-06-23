//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol GreenCardLoading {
	init(networkManager: NetworkManaging, cryptoManager: CryptoManaging, walletManager: WalletManaging)
	func signTheEventsIntoGreenCardsAndCredentials(completion: @escaping (Result<Void, GreenCardLoader.Error>) -> Void)
}

class GreenCardLoader: GreenCardLoading, Logging {

	enum Error: Swift.Error {
		case failedToSave
		case failedToPrepareIssue
		
		case preparingIssue117
		case stoken118
		case credentials119

		case serverBusy
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

	func signTheEventsIntoGreenCardsAndCredentials(completion: @escaping (Result<Void, Error>) -> Void) {

		networkManager.prepareIssue { (prepareIssueResult: Result<PrepareIssueEnvelope, NetworkError>) in

			switch prepareIssueResult {
				case .failure(let networkError):
					self.logError("error: \(networkError)")
					if networkError == .serverBusy {
						completion(.failure(.serverBusy))
					} else {
						completion(.failure(.preparingIssue117))
					}

				case .success(let prepareIssueEnvelope):
					guard let nonce = prepareIssueEnvelope.prepareIssueMessage.base64Decoded() else {
						self.logError("Can't save the nonce / prepareIssueMessage")
						completion(.failure(.failedToPrepareIssue))
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
								self.storeGreenCards(response: greenCardResponse) { greenCardsSaved in
									guard greenCardsSaved else {
										self.logError("Failed to save greenCards")
										completion(.failure(.failedToSave))
										return
									}
									
									completion(.success(()))
								}
						}
					}
			}
		}
	}

	private func fetchGreenCards(_ onCompletion: @escaping (Result<RemoteGreenCards.Response, Error>) -> Void) {

		let signedEvents = walletManager.fetchSignedEvents()

		guard let issueCommitmentMessage = cryptoManager.generateCommitmentMessage(),
			let utf8 = issueCommitmentMessage.data(using: .utf8),
			let stoken = cryptoManager.getStoken()
		else {
			onCompletion(.failure(.stoken118))
			return
		}

		let dictionary: [String: AnyObject] = [
			"stoken": stoken as AnyObject,
			"events": signedEvents as AnyObject,
			"issueCommitmentMessage": utf8.base64EncodedString() as AnyObject
		]

		self.networkManager.fetchGreencards(dictionary: dictionary) { [weak self] (result: Result<RemoteGreenCards.Response, NetworkError>) in
			switch result {
				case let .success(greencardResponse):
					self?.logVerbose("ok: \(greencardResponse)")
					onCompletion(.success(greencardResponse))
				case let .failure(error):
					self?.logError("error: \(error)")

					if error == .serverBusy {
						onCompletion(.failure(.serverBusy))
					} else {
						onCompletion(.failure(.credentials119))
					}
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

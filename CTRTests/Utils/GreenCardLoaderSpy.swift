//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class GreenCardLoaderSpy: GreenCardLoading {

	required init(networkManager: NetworkManaging, cryptoManager: CryptoManaging, walletManager: WalletManaging) {}

	var invokedSignTheEventsIntoGreenCardsAndCredentials = false
	var invokedSignTheEventsIntoGreenCardsAndCredentialsCount = 0
	var stubbedSignTheEventsIntoGreenCardsAndCredentialsResponseEvaluatorResult: (RemoteGreenCards.Response, Void)?
	var stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult: (Result<Void, Swift.Error>, Void)?

	func signTheEventsIntoGreenCardsAndCredentials(
		responseEvaluator: ((RemoteGreenCards.Response) -> Bool)?,
		completion: @escaping (Result<Void, Swift.Error>
		) -> Void) {
		invokedSignTheEventsIntoGreenCardsAndCredentials = true
		invokedSignTheEventsIntoGreenCardsAndCredentialsCount += 1
		if let result = stubbedSignTheEventsIntoGreenCardsAndCredentialsResponseEvaluatorResult {
			_ = responseEvaluator?(result.0)
		}
		if let result = stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult {
			completion(result.0)
		}
	}
}

extension GreenCardLoaderSpy {

	convenience init() {

		self.init(networkManager: NetworkSpy(), cryptoManager: CryptoManagerSpy(), walletManager: WalletManagerSpy())
	}
}

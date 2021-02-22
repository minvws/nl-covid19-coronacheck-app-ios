/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class ProofManagingSpy: ProofManaging {

	var fetchCoronaTestProvidersCalled = false
	var fetchTestTypesCalled = false
	var fetchTestResultCalled = false
	var fetchNonceCalled = false
	var fetchSignedTestResultCalled = false
	var getTestProviderCalled = false
	var getTestWrapperCalled = false
	var getSignedWrapperCalled = false
	var removeTestWrapperCalled = false

	var testResultWrapper: TestResultWrapper?
	var nonceError: Error?
	var shouldNonceComplete = false
	var signedTestResultError: Error?
	var shouldSignedTestResultComplete = false
	var signedTestResultState = SignedTestResultState.valid

	required init() {
		// Demanded by protocol
	}

	func fetchCoronaTestProviders() {

		fetchCoronaTestProvidersCalled = true
	}

	func fetchTestTypes() {

		fetchTestTypesCalled = true
	}

	func fetchTestResult(
		_ token: RequestToken,
		code: String?, provider: TestProvider,
		oncompletion: @escaping (Result<TestResultWrapper, Error>) -> Void) {

		fetchTestResultCalled = true
	}

	func fetchNonce(
		oncompletion: @escaping (() -> Void),
		onError: @escaping ((Error) -> Void)) {

		fetchNonceCalled = true
		if let error = nonceError {
			onError(error)
		} else {
			if shouldNonceComplete {
				oncompletion()
			}
		}
	}

	func fetchSignedTestResult(
		oncompletion: @escaping ((SignedTestResultState) -> Void),
		onError: @escaping ((Error) -> Void)) {

		fetchSignedTestResultCalled = true
		if let error = signedTestResultError {
			onError(error)
		} else {
			if shouldSignedTestResultComplete {
				oncompletion(signedTestResultState)
			}
		}
	}

	func getTestProvider(_ token: RequestToken) -> TestProvider? {

		getTestProviderCalled = true
		return nil
	}

	func getTestWrapper() -> TestResultWrapper? {

		getTestWrapperCalled = true
		return testResultWrapper
	}

	func getSignedWrapper() -> SignedResponse? {

		getSignedWrapperCalled = true
		return nil
	}

	func removeTestWrapper() {

		removeTestWrapperCalled = true
	}
}

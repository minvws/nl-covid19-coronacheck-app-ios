/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR
import ViewControllerPresentationSpy

class UnrecoverableErrorCoordinatorTests: XCTestCase {
	
	private func makeSUT(
		error: Error,
		file: StaticString = #filePath,
		line: UInt = #line) -> UnrecoverableErrorCoordinator {
		
		let sut = UnrecoverableErrorCoordinator(error: error)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return sut
	}
	
	// MARK: - Tests
	
	func test_start_databaseFull() {
		
		// Given
		let error = DataStoreManager.Error.diskFull
		let sut = makeSUT(error: error)
		
		// When
		sut.start()
		
		// Then
		expect(sut.window.rootViewController is AppStatusViewController) == true
		expect(sut.navigationController.viewControllers).to(beEmpty())
	}
	
	func test_start_crashReport() {
		
		// Given
		let error = NSError(domain: "CoronaCheck", code: -1)
		let sut = makeSUT(error: error)
		let alertVerifier = AlertVerifier()
		
		// When
		sut.start()
		
		// Then
		expect(sut.window.rootViewController is AppStatusViewController) != true
		expect(sut.navigationController.viewControllers).to(haveCount(1))
		
		alertVerifier.verify(
			title: L.general_unrecoverableError_restartTheApp_title(),
			message: L.general_unrecoverableError_restartTheApp_message(),
			animated: false,
			actions: [
				.default(L.generalClose())
			]
		)
	}
	
	func test_consumeLink() {
		
		// Given
		let error = DataStoreManager.Error.diskFull
		let sut = makeSUT(error: error)
		
		let universalLink = UniversalLink.redeemHolderToken(requestToken: RequestToken(
			token: "STXT2VF3389TJ2",
			protocolVersion: "3.0",
			providerIdentifier: "XXX"
		))
		
		// When
		let result = sut.consume(universalLink: universalLink)
		
		// Then
		expect(result) == false
	}
}

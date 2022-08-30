/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import ViewControllerPresentationSpy

class UnrecoverableErrorCoordinatorTests: XCTestCase {

	private var sut: UnrecoverableErrorCoordinator!
	
	// MARK: - Tests

	func test_start_databaseFull() {
		
		// Given
		let error = DataStoreManager.Error.diskFull
		sut = UnrecoverableErrorCoordinator(error: error)
		
		// When
		sut.start()
		
		// Then
		expect(self.sut.window.rootViewController is AppStatusViewController) == true
		expect(self.sut.navigationController.viewControllers).to(beEmpty())
	}
	
	func test_start_crashReport_doBypassCanSendMail() {
		
		// Given
		let error = NSError(domain: "CoronaCheck", code: -1)
		sut = UnrecoverableErrorCoordinator(error: error, bypassCanSendMail: true)
		let alertVerifier = AlertVerifier()
		
		// When
		sut.start()
		
		// Then
		expect(self.sut.window.rootViewController is AppStatusViewController) != true
		expect(self.sut.navigationController.viewControllers).to(haveCount(1))
		
		alertVerifier.verify(
			title: L.general_unrecoverableError_sendCrashReport_title(),
			message: L.general_unrecoverableError_sendCrashReport_message(),
			animated: false,
			actions: [
				.default(L.general_unrecoverableError_sendCrashReport_action()),
				.cancel(L.generalClose())
			]
		)
	}
	
	func test_start_crashReport_doNotBypassCanSendMail() {
		
		// Given
		let error = NSError(domain: "CoronaCheck", code: -1)
		sut = UnrecoverableErrorCoordinator(error: error, bypassCanSendMail: false)
		let alertVerifier = AlertVerifier()
		
		// When
		sut.start()
		
		// Then
		expect(self.sut.window.rootViewController is AppStatusViewController) != true
		expect(self.sut.navigationController.viewControllers).to(haveCount(1))
		
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
		sut = UnrecoverableErrorCoordinator(error: error)
		
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

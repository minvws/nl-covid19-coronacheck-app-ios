/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckTest

class BaseTest: XCTestCase {
	
	let app = XCUIApplication()
	let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
	let loginTimeout = 15.0
	
	var disclosureMode = DisclosureMode.mode0G
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		app.launchArguments.append("-resetOnStart")
		app.launchArguments.append("-skipOnboarding")
		app.launchArguments.append("-skipArchiveEndState")
		app.launchArguments.append("-disableTransitions")
		app.launchArguments.append("-showAccessibilityLabels")
		app.launchArguments.append(disclosureMode.rawValue)
		app.launch()
		XCTAssertTrue(app.waitForExistence(timeout: loginTimeout), "App did not start")
		XCTAssertTrue(app.buttons["MenuButton"].waitForExistence(timeout: loginTimeout), "Overview was not loaded in time")
		
		continueAfterFailure = false
	}
	
	override func tearDownWithError() throws {
		makeScreenShot(name: "Teardown")
		try super.tearDownWithError()
	}
}

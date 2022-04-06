/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest

class BaseTest: XCTestCase {
	
	let app = XCUIApplication()
	let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
	let loginTimeout = 15.0
	
	var disclosureMode = DisclosureMode.mode0G
	let ctbInUse = false
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		app.launchArguments.append(contentsOf: ["-resetOnStart"])
		app.launchArguments.append(contentsOf: ["-skipOnboarding"])
		app.launchArguments.append(contentsOf: ["-showAccessibilityLabels"])
		app.launchArguments.append(contentsOf: [disclosureMode.rawValue])
		app.launch()
		XCTAssertTrue(app.waitForExistence(timeout: loginTimeout), "App did not start")
		
		continueAfterFailure = false
	}
	
	override func tearDownWithError() throws {
		makeScreenShot(name: "Teardown")
		try super.tearDownWithError()
	}
}

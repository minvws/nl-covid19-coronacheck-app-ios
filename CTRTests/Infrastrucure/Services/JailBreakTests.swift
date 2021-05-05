/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class JailBreakTests: XCTestCase {

	private var sut: JailBreakDetector!
	private var userSettingSpy: UserSettingsSpy!

	override func setUp() {

		super.setUp()

		userSettingSpy = UserSettingsSpy()
		sut = JailBreakDetector(userSettings: userSettingSpy)
	}

	func test_shouldWarnUser() {

		// Given
		userSettingSpy.stubbedJailbreakWarningShown = false

		// When
		let shouldWarnUser = sut.shouldWarnUser()

		// Then
		expect(shouldWarnUser) == true
		expect(self.userSettingSpy.invokedJailbreakWarningShownGetter) == true
	}

	func test_shouldWarnUser_alreadyWarned() {

		// Given
		userSettingSpy.stubbedJailbreakWarningShown = true

		// When
		let shouldWarnUser = sut.shouldWarnUser()

		// Then
		expect(shouldWarnUser) == false
		expect(self.userSettingSpy.invokedJailbreakWarningShownGetter) == true
	}

	func test_warningHasBeenSeen() {

		// Given
		userSettingSpy.stubbedJailbreakWarningShown = false

		// When
		sut.warningHasBeenSeen()

		// Then
		expect(self.userSettingSpy.invokedJailbreakWarningShownSetter) == true
		expect(self.userSettingSpy.invokedJailbreakWarningShown) == true
	}

	func test_isJailBroken() {

		// Given
		// Can't simulate a jailbroken device. 

		// When
		let result = sut.isJailBroken()

		// Then
		expect(result) == false
	}
}

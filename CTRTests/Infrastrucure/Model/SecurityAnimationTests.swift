/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
@testable import CTR

class SecurityAnimationTests: XCTestCase {
	
	var environmentalSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		environmentalSpies = setupEnvironmentSpies()
	}
	
	func testDomesticSeasonalBoundaries() {
		
		// Winter
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 12, day: 21).date! }
		expect(SecurityAnimation.domesticAnimation.name) == "domesticWinterAnimation"
		
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 3, day: 20).date! }
		expect(SecurityAnimation.domesticAnimation.name) == "domesticWinterAnimation"
		
		// Summer
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 3, day: 21).date! }
		expect(SecurityAnimation.domesticAnimation.name) == "domesticSummerAnimation"
		
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 12, day: 20).date! }
		expect(SecurityAnimation.domesticAnimation.name) == "domesticSummerAnimation"
	}
	
	func testInternationalSeasonalBoundaries() {
		
		// Winter
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 12, day: 21).date! }
		expect(SecurityAnimation.internationalAnimation.name) == "internationalWinterAnimation"
		
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 3, day: 20).date! }
		expect(SecurityAnimation.internationalAnimation.name) == "internationalWinterAnimation"
		
		// Summer
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 3, day: 21).date! }
		expect(SecurityAnimation.internationalAnimation.name) == "internationalSummerAnimation"
		
		Current.now = { DateComponents(calendar: .autoupdatingCurrent, month: 12, day: 20).date! }
		expect(SecurityAnimation.internationalAnimation.name) == "internationalSummerAnimation"
	}
}

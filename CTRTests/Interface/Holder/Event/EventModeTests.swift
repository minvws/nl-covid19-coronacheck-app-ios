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

class EventModeTests: XCTestCase {
	
	func test_asList() {
		
		expect(EventMode.paperflow.asList) == nil
		expect(EventMode.vaccinationassessment.asList) == ["vaccinationassessment"]
		expect(EventMode.vaccinationAndPositiveTest.asList) == ["vaccination", "positivetest"]
		expect(EventMode.recovery.asList) == ["positivetest"]
		expect(EventMode.test(.ggd).asList) == ["negativetest"]
		expect(EventMode.test(.commercial).asList) == ["negativetest"]
		expect(EventMode.vaccination.asList) == ["vaccination"]
	}
}

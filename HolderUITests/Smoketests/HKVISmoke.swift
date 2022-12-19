/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

class DccValidVac2of2NL: BaseTest {
	
	let vaccination = TestData.validVac2of2NL
	
	override func setUpWithError() throws {
		app.launchArguments.append("-scanneddcc:" + vaccination.dcc!)
		app.launchArguments.append("-couplingCode:" + vaccination.couplingCode!)
		
		try super.setUpWithError()
	}
	
	func test_validVac2of2NL() {
		addScannedQR()
		proceedToOverview()
		assertInternationalVaccination(of: vaccination, dose: "2/2")
		
		viewQRCode(of: .vaccination)
		assertInternationalVaccinationQR(of: vaccination, dose: "2/2")
	}
}

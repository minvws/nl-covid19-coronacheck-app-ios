/*
 * Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckTest
import CoronaCheckUI
@testable import CTR

final class MigrationOnboardingFactoryTests: XCTestCase {

	var sut: MigrationOnboardingFactory!
	
	func test_getImportInstructions() {
		
		// Given
		sut = MigrationOnboardingFactory()
		
		// When
		let pages = sut.getImportInstructions()
		
		// Then
		expect(pages).to(haveCount(2))
		expect(pages.first?.title) == L.holder_startMigration_toThisDevice_onboarding_step1_title()
		expect(pages.first?.content) == L.holder_startMigration_toThisDevice_onboarding_step1_message()
		expect(pages.last?.title) == L.holder_startMigration_toThisDevice_onboarding_step2_title()
		expect(pages.last?.content) == L.holder_startMigration_toThisDevice_onboarding_step2_message()
	}

	func test_getExportInstructions() {
		
		// Given
		sut = MigrationOnboardingFactory()
		
		// When
		let pages = sut.getExportInstructions()
		
		// Then
		expect(pages).to(haveCount(2))
		expect(pages.first?.title) == L.holder_startMigration_toOtherDevice_onboarding_step1_title()
		expect(pages.first?.content) == L.holder_startMigration_toOtherDevice_onboarding_step1_message()
		expect(pages.last?.title) == L.holder_startMigration_toOtherDevice_onboarding_step2_title()
		expect(pages.last?.content) == L.holder_startMigration_toOtherDevice_onboarding_step2_message()
	}
}

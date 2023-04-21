/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Models
import Resources

protocol MigrationOnboardingFactoryProtocol {
	
	func getImportInstructions() -> [PagedAnnoucementItem]
	func getExportInstructions() -> [PagedAnnoucementItem]
}

struct MigrationOnboardingFactory: MigrationOnboardingFactoryProtocol {
	
	func getImportInstructions() -> [Models.PagedAnnoucementItem] {
		
		return [
			PagedAnnoucementItem(
				title: L.holder_startMigration_toThisDevice_onboarding_step1_title(),
				content: L.holder_startMigration_toThisDevice_onboarding_step1_message(),
				image: I.migrationInstruction1(),
				tagline: L.holder_startMigration_onboarding_step("1"),
				step: 0,
				nextButtonTitle: L.holder_startMigration_toThisDevice_onboarding_nextButton()
			),
			PagedAnnoucementItem(
				title: L.holder_startMigration_toThisDevice_onboarding_step2_title(),
				content: L.holder_startMigration_toThisDevice_onboarding_step2_message(),
				image: I.migrationInstruction2(),
				tagline: L.holder_startMigration_onboarding_step("2"),
				step: 1,
				nextButtonTitle: L.holder_startMigration_toThisDevice_onboarding_nextButton()
			)
		]
	}

	func getExportInstructions() -> [Models.PagedAnnoucementItem] {
		
		return [
			PagedAnnoucementItem(
				title: L.holder_startMigration_toOtherDevice_onboarding_step1_title(),
				content: L.holder_startMigration_toOtherDevice_onboarding_step1_message(),
				image: I.migrationInstruction1(),
				tagline: L.holder_startMigration_onboarding_step("1"),
				step: 0,
				nextButtonTitle: L.holder_startMigration_toOtherDevice_onboarding_nextButton()
			),
			PagedAnnoucementItem(
				title: L.holder_startMigration_toOtherDevice_onboarding_step2_title(),
				content: L.holder_startMigration_toOtherDevice_onboarding_step2_message(),
				image: I.migrationInstruction2(),
				tagline: L.holder_startMigration_onboarding_step("2"),
				step: 1,
				nextButtonTitle: L.holder_startMigration_toOtherDevice_onboarding_nextButton()
			)
		]
	}
}

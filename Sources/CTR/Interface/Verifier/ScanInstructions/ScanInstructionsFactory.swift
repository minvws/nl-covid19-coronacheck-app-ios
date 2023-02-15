/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import Resources

enum ScanInstructionsStep: CaseIterable {
	case scanQR, checkTheDetails, checkOnlyTheVisibleData, greenScreenIsAccess, verificationPoliciyAccess, redScreenNowWhat
	
	var animationName: String {
		switch self {
			case .scanQR:
				return "Scanner_1"
			case .checkTheDetails:
				return "Scanner_2"
			case .checkOnlyTheVisibleData:
				return "Scanner_3"
			case .greenScreenIsAccess:
				return "Scanner_4"
			case .verificationPoliciyAccess:
				return "Scanner_4"
			case .redScreenNowWhat:
				return "Scanner_5"
		}
	}
}

struct ScanInstructionsItem {
	let title: String
	let message: String
	let animationName: String?
	let step: ScanInstructionsStep
}

protocol ScanInstructionsFactoryProtocol {
	func create() -> [ScanInstructionsItem]
}

struct ScanInstructionsFactory: ScanInstructionsFactoryProtocol {
	
	func create() -> [ScanInstructionsItem] {
		
		var pages = [
			ScanInstructionsItem(
				title: L.verifierScaninstructionsScanQRTitle(),
				message: L.verifierScaninstructionsScanQRContent(),
				animationName: ScanInstructionsStep.scanQR.animationName,
				step: .scanQR
			),
			ScanInstructionsItem(
				title: L.verifierScaninstructionsCheckthedetailsTitle(),
				message: L.verifierScaninstructionsCheckthedetailsMessage(),
				animationName: ScanInstructionsStep.checkTheDetails.animationName,
				step: .checkTheDetails
			),
			ScanInstructionsItem(
				title: L.verifierScaninstructionsCheckonlythevisibledataTitle(),
				message: L.verifierScaninstructionsCheckonlythevisibledataMessage(),
				animationName: ScanInstructionsStep.checkOnlyTheVisibleData.animationName,
				step: .checkOnlyTheVisibleData
			),
			ScanInstructionsItem(
				title: L.verifierScaninstructionsGreenScreenIsAccessTitle(),
				message: L.verifierScaninstructionsGreenScreenIsAccessMessage(),
				animationName: ScanInstructionsStep.greenScreenIsAccess.animationName,
				step: .greenScreenIsAccess
			),
			ScanInstructionsItem(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				animationName: ScanInstructionsStep.redScreenNowWhat.animationName,
				step: .redScreenNowWhat
			)
		]
		
		if Current.featureFlagManager.is1GVerificationPolicyEnabled() {
			pages[3] = ScanInstructionsItem(
				title: L.scan_instructions_4_title_1G(),
				message: L.scan_instructions_4_description_1G(),
				animationName: ScanInstructionsStep.verificationPoliciyAccess.animationName,
				step: .verificationPoliciyAccess
			)
		}
		return pages
	}
}

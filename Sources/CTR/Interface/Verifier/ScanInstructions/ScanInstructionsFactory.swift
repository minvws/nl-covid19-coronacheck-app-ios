/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum ScanInstructionsStep: CaseIterable {
	case scanQR, checkTheDetails, checkOnlyTheVisibleData, redScreenNowWhat
}

struct ScanInstructionsPage {
	let title: String
	let message: String
	let image: UIImage?
	let step: ScanInstructionsStep
}

protocol ScanInstructionsFactoryProtocol {
	func create() -> [ScanInstructionsPage]
}

struct ScanInstructionsFactory: ScanInstructionsFactoryProtocol {

	func create() -> [ScanInstructionsPage] {

		let pages = [
			ScanInstructionsPage(
				title: L.verifierScaninstructionsScanQRTitle(),
				message: L.verifierScaninstructionsScanQRContent(),
				image: I.onboarding.who(),
				step: .scanQR
			),
			ScanInstructionsPage(
				title: L.verifierScaninstructionsCheckthedetailsTitle(),
				message: L.verifierScaninstructionsCheckthedetailsMessage(),
				image: I.newScanInstructions.checkTheDetails(),
				step: .checkTheDetails
			),
			ScanInstructionsPage(
				title: L.verifierScaninstructionsCheckonlythevisibledataTitle(),
				message: L.verifierScaninstructionsCheckonlythevisibledataMessage(),
				image: I.newScanInstructions.checkOnlyTheVisibleData(),
				step: .checkOnlyTheVisibleData
			),
			ScanInstructionsPage(
				title: L.verifierScaninstructionsRedscreennowwhatTitle(),
				message: L.verifierScaninstructionsRedscreennowwhatMessage(),
				image: I.newScanInstructions.redScreenNowWhat(),
				step: .redScreenNowWhat
			)
		]

		return pages
	}
}

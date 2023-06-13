/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Models
import Resources

protocol StartPDFExportFactoryProtocol {
	
	func getExportInstructions() -> [PagedAnnoucementItem]
}

struct StartPDFExportFactory: StartPDFExportFactoryProtocol {
	
	func getExportInstructions() -> [Models.PagedAnnoucementItem] {
		
		return [
			PagedAnnoucementItem(
				title: L.holder_pdfExport_start_title(),
				content: L.holder_pdfExport_start_message(),
				image: I.onboarding.validity(),
				tagline: nil,
				step: 0,
				nextButtonTitle: L.holder_pdfExport_start_buttonTitle()
			)
		]
	}
}

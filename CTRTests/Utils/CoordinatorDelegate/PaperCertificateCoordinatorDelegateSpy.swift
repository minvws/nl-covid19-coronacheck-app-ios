//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class PaperCertificateCoordinatorDelegateSpy: PaperCertificateCoordinatorDelegate {

	var invokedUserDidSubmitPaperCertificateToken = false
	var invokedUserDidSubmitPaperCertificateTokenCount = 0
	var invokedUserDidSubmitPaperCertificateTokenParameters: (token: String, Void)?
	var invokedUserDidSubmitPaperCertificateTokenParametersList = [(token: String, Void)]()

	func userDidSubmitPaperCertificateToken(token: String) {
		invokedUserDidSubmitPaperCertificateToken = true
		invokedUserDidSubmitPaperCertificateTokenCount += 1
		invokedUserDidSubmitPaperCertificateTokenParameters = (token, ())
		invokedUserDidSubmitPaperCertificateTokenParametersList.append((token, ()))
	}

	var invokedPresentInformationPage = false
	var invokedPresentInformationPageCount = 0
	var invokedPresentInformationPageParameters: (title: String, body: String, hideBodyForScreenCapture: Bool)?
	var invokedPresentInformationPageParametersList = [(title: String, body: String, hideBodyForScreenCapture: Bool)]()

	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool) {
		invokedPresentInformationPage = true
		invokedPresentInformationPageCount += 1
		invokedPresentInformationPageParameters = (title, body, hideBodyForScreenCapture)
		invokedPresentInformationPageParametersList.append((title, body, hideBodyForScreenCapture))
	}
}

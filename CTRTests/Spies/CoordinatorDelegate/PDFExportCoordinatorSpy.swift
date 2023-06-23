/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR
import Shared
import Models
import ReusableViews

class PDFExportCoordinatorSpy: PDFExportCoordinatorDelegate, OpenUrlProtocol {

	var invokedUserWishesToStart = false
	var invokedUserWishesToStartCount = 0

	func userWishesToStart() {
		invokedUserWishesToStart = true
		invokedUserWishesToStartCount += 1
	}

	var invokedUserWishesToExport = false
	var invokedUserWishesToExportCount = 0

	func userWishesToExport() {
		invokedUserWishesToExport = true
		invokedUserWishesToExportCount += 1
	}

	var invokedDisplayError = false
	var invokedDisplayErrorCount = 0
	var invokedDisplayErrorParameters: (content: Content, Void)?
	var invokedDisplayErrorParametersList = [(content: Content, Void)]()

	func displayError(content: Content) {
		invokedDisplayError = true
		invokedDisplayErrorCount += 1
		invokedDisplayErrorParameters = (content, ())
		invokedDisplayErrorParametersList.append((content, ()))
	}

	var invokedUserWishesToShare = false
	var invokedUserWishesToShareCount = 0
	var invokedUserWishesToShareParameters: (path: URL, Void)?
	var invokedUserWishesToShareParametersList = [(path: URL, Void)]()

	func userWishesToShare(_ path: URL) {
		invokedUserWishesToShare = true
		invokedUserWishesToShareCount += 1
		invokedUserWishesToShareParameters = (path, ())
		invokedUserWishesToShareParametersList.append((path, ()))
	}

	var invokedExportFailed = false
	var invokedExportFailedCount = 0

	func exportFailed() {
		invokedExportFailed = true
		invokedExportFailedCount += 1
	}

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, Void)?
	var invokedOpenUrlParametersList = [(url: URL, Void)]()

	func openUrl(_ url: URL) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, ())
		invokedOpenUrlParametersList.append((url, ()))
	}
}
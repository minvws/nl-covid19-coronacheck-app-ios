/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class ErrorStateViewModel: Logging {

	@Bindable private(set) var content: Content

	private var backbuttonAction: () -> Void

	init(content: Content, backAction: @escaping () -> Void) {

		self.content = content
		self.backbuttonAction = backAction
	}

	func backButtonTapped() {

		backbuttonAction()
	}
}

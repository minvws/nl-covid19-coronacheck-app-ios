/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class ContentViewModel: Logging {

	@Bindable private(set) var content: Content
	
	let showBackButton: Bool
	let allowsSwipeBack: Bool
	private var backbuttonAction: (() -> Void)?

	init(content: Content, backAction: (() -> Void)?, allowsSwipeBack: Bool) {

		self.content = content
		self.backbuttonAction = backAction
		self.showBackButton = backbuttonAction != nil
		self.allowsSwipeBack = allowsSwipeBack
	}

	func backButtonTapped() {

		backbuttonAction?()
	}
}

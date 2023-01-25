/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

class BottomSheetContentViewModel {

	// MARK: - Bindable

	@Bindable private(set) var title: String
	@Bindable private(set) var body: String
	@Bindable private(set) var secondaryButtonTitle: String?

	@Bindable private(set) var hideForCapture: Bool = false

	// MARK: - Private
	private let linkTapHander: ((URL) -> Void)?
	private let screenCaptureDetector = ScreenCaptureDetector()
	internal let content: Content
	
	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - title: The title of the page
	///   - message: The message of the page
	init(
		content: Content,
		linkTapHander: ((URL) -> Void)? = nil, // todo: merge this into Content?
		hideBodyForScreenCapture: Bool = false) {

		self.content = content
		self.title = content.title
		self.body = content.body ?? ""
		self.secondaryButtonTitle = content.secondaryActionTitle
		self.linkTapHander = linkTapHander

		if hideBodyForScreenCapture {
			screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
				self?.hideForCapture = isBeingCaptured
			}
		}
	}

	// MARK: - Methods

	func userDidTapURL(url: URL) {
		linkTapHander?(url)
	}

	func userDidTapSecondaryButton() {
		content.secondaryAction?()
	}
}

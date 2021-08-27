/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
typealias DisplayContent = (view: UIView, customSpacing: CGFloat)

class DisplayContentViewModel {

	/// Coordination Delegate
	weak var coordinator: (Dismissable)?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The array of content
	@Bindable private(set) var content: [DisplayContent] = []

	@Bindable private(set) var hideForCapture: Bool = false

	private let screenCaptureDetector = ScreenCaptureDetector()

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - title: the title of the scene
	///   - content: an array of content
	init(
		coordinator: Dismissable,
		title: String,
		content: [DisplayContent]) {

		self.coordinator = coordinator
		self.content = content
		self.title = title

		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.hideForCapture = isBeingCaptured
		}
	}

	/// User wants to dismiss the scene
	func dismiss() {

		coordinator?.dismiss()
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class InformationViewModel: PreventableScreenCapture {

	/// Dismissable Delegate
	weak var coordinator: Dismissable?

	var hideBodyForScreenCapture = false

	// MARK: - Bindable

	/// The title of the information page
	@Bindable private(set) var title: String

	/// The message of the information page
	@Bindable private(set) var message: String

	// MARK: - Private
	private let linkTapHander: ((URL) -> Void)?

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - title: The title of the page
	///   - message: The message of the page
	init(
		coordinator: Dismissable,
		title: String,
		message: String,
		linkTapHander: ((URL) -> Void)? = nil,
		hideBodyForScreenCapture: Bool = false) {

		self.coordinator = coordinator
		self.title = title
		self.message = message
		self.linkTapHander = linkTapHander
		self.hideBodyForScreenCapture = hideBodyForScreenCapture
		super.init()
	}

	// MARK: - Methods

	/// The user tapped on the next button
	func dismiss() {

		// Notify the coordinator
		coordinator?.dismiss()
	}

	func userDidTapURL(url: URL) {
		linkTapHander?(url)
	}

	override func preventScreenCapture() {

		// only prevent when required
		if hideBodyForScreenCapture {
			super.preventScreenCapture()
		}
	}
}

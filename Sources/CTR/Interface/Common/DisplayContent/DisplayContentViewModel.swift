/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
typealias Content = [(view: UIView, customSpacing: CGFloat)]

class DisplayContentViewModel: Logging {

	var loggingCategory: String = "DisplayContentViewModel"

	/// Coordination Delegate
	weak var coordinator: (Dismissable)?

	@Bindable private (set) var title: String

	@Bindable private (set) var content: Content = []

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(
		coordinator: Dismissable,
		title: String,
		content: Content) {

		self.coordinator = coordinator
		self.content = content
		self.title = title
	}

	func dismiss() {

		coordinator?.dismiss()
	}
}

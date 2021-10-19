/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class VerifiedInfoViewModel: Logging {
	
	/// The coordinator delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?

	// MARK: - Bindable

	/// The title of the information page
	@Bindable private(set) var title: String

	/// The message of the information page
	@Bindable private(set) var message: String
	
	/// The title of the button
	@Bindable private(set) var primaryTitle: String
	
	/// The primary button icon
	@Bindable private(set) var primaryButtonIcon: UIImage?

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: The coordinator delegate
	init(coordinator: (VerifierCoordinatorDelegate & Dismissable)) {

		self.coordinator = coordinator
		self.title = L.verifierResultCheckTitle()
		self.message = L.verifierResultCheckText()
		self.primaryTitle = L.verifierResultCheckButton()
		self.primaryButtonIcon = I.deeplinkScan()
	}

	// MARK: - Methods

	/// The user tapped on the button
	@objc func onTap() {

		coordinator?.dismiss()
		coordinator?.navigateToScan()
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
typealias DisplayContent = (view: UIView, customSpacing: CGFloat)

class DeniedQRScanMoreInfoViewModel {

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
	init(coordinator: Dismissable) {

		self.coordinator = coordinator
		
		// By default, unordered lists have a space above them in HTML
		let bulletSpacing: CGFloat = -24
		let spacing: CGFloat = 16

		self.title = L.verifierDeniedTitle()
		self.content = [
			(TextView(htmlText: Current.featureFlagManager.is1GPolicyEnabled() ? L.verifierDeniedMessageOne_2G() : L.verifierDeniedMessageOne()), spacing),
			(TextView(htmlText: L.verifierDeniedMessageTwo()), bulletSpacing),
			(TextView(htmlText: L.verifierDeniedMessageThree()), spacing),
			(TextView(htmlText: L.verifierDeniedMessageFour()), 0),
			(TextView(htmlText: L.verifierDeniedMessageFive()), spacing),
			(TextView(htmlText: Current.featureFlagManager.is1GPolicyEnabled() ? L.verifierDeniedMessageSix_2G() : L.verifierDeniedMessageSix()), spacing)
		]

		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.hideForCapture = isBeingCaptured
		}
	}

	/// User wants to dismiss the scene
	func dismiss() {

		coordinator?.dismiss()
	}
}

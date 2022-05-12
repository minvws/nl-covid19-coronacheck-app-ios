/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
typealias DisplayContent = (view: UIView, customSpacing: CGFloat)

class DeniedQRScanMoreInfoViewModel {

	/// Coordination Delegate
	weak var coordinator: (Dismissable)?
	
	weak var verificationPolicyManager: VerificationPolicyManaging? = Current.verificationPolicyManager

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
		
		// Show the 1G text only when 1G policy is enabled and the current state.
		// -> do not show it when both policies are enabled, but the current scan mode is 3G
		let shouldDisplay1GText = verificationPolicyManager?.state == .policy1G
		
		self.content = [
			(TextView(htmlText: shouldDisplay1GText ? L.verifierDeniedMessageOne_1G() : L.verifierDeniedMessageOne()), spacing),
			(TextView(htmlText: L.verifierDeniedMessageTwo()), bulletSpacing),
			(TextView(htmlText: shouldDisplay1GText ? L.verifierDeniedMessageThree_1G() : L.verifierDeniedMessageThree()), spacing),
			(TextView(htmlText: L.verifierDeniedMessageFour()), 0),
			(TextView(htmlText: L.verifierDeniedMessageFive()), spacing),
			(TextView(htmlText: shouldDisplay1GText ? L.verifierDeniedMessageSix_1G() : L.verifierDeniedMessageSix()), spacing)
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

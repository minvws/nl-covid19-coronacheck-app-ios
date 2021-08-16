/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierResultView: BaseView {
	
	enum Result {
		
		case verified
		case denied
		case demo
		
		var colors: UIColor {
			switch self {
				case .verified: return Theme.colors.access
				case .demo: return Theme.colors.grey4
				case .denied: return Theme.colors.denied
			}
		}
	}

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		static let imageMargin: CGFloat = 70.0
		static let verifiedMessageMargin: CGFloat = UIDevice.current.isSmallScreen ? 95.0 : 108.0
		static let identityTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 20.0
	}

	let checkIdentityView: VerifierCheckIdentityView = {

		let view = VerifierCheckIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private var imageHeightConstraint: NSLayoutConstraint?

	/// setup the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		checkIdentityView.alpha = 0
	}
	
	func setup(for result: Result) {
		switch result {
			case .verified:
				let view = VerifiedView()
				view.backgroundColor = result.colors
				view.title = L.verifierResultAccessTitle()
				setup(view: view)
				revealIdentityView(for: result)
			case .demo:
				let view = VerifiedView()
				view.backgroundColor = result.colors
				view.title = L.verifierResultDemoTitle()
				setup(view: view)
				revealIdentityView(for: result)
			case .denied:
				let view = DeniedView()
				view.title = L.verifierResultDeniedTitle()
				setup(view: view)
		}
	}

	func layoutForOrientation() {

		if traitCollection.verticalSizeClass == .compact ||
			OrientationUtility.currentOrientation() == .landscapeLeft ||
			OrientationUtility.currentOrientation() == .landscapeRight {
			// Image should be 0.3 times the screen height in a compact vertical screen
			imageHeightConstraint?.isActive = true
		} else {
			// Image height should be bound by the width only
			imageHeightConstraint?.isActive = false
		}
	}
}

private extension VerifierResultView {
	
	func setup(view: UIView) {
		
		view.embed(in: self)
	}
	
	func revealIdentityView(for result: Result) {
		
		checkIdentityView.backgroundColor = result.colors
		setup(view: checkIdentityView)

		UIView.animate(withDuration: 0.25, delay: 0.8, options: .curveLinear) {
			self.checkIdentityView.alpha = 1
		} completion: { _ in
//			self.accessibilityElements = [self.checkIdentityView, self.primaryButton]
//			UIAccessibility.post(notification: .screenChanged, argument: self.checkIdentityView)
		}
	}
}

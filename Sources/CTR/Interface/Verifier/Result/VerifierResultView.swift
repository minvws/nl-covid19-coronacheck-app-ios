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

		enum Animation {
			static let duration: TimeInterval = 0.25
			static let delay: TimeInterval = 0.8
		}
	}

	let checkIdentityView: VerifierCheckIdentityView = {

		let view = VerifierCheckIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private var imageHeightConstraint: NSLayoutConstraint?

	/// Setup the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
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
				view.footerButtonView.primaryButtonTappedCommand = scanNextTappedCommand
				view.secondaryButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
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
	
	/// The user tapped on the primary button
	var scanNextTappedCommand: (() -> Void)?
	
	/// The user tapped on the secondary button in the denied view
	var readMoreTappedCommand: (() -> Void)?
}

private extension VerifierResultView {
	
	func setup(view: UIView) {
		
		view.embed(in: self)
	}
	
	func revealIdentityView(for result: Result) {
		
		checkIdentityView.backgroundColor = result.colors
		checkIdentityView.footerButtonView.primaryButtonTappedCommand = scanNextTappedCommand
		checkIdentityView.alpha = 0
		setup(view: checkIdentityView)

		UIView.animate(withDuration: ViewTraits.Animation.duration,
					   delay: ViewTraits.Animation.delay,
					   options: .curveLinear) {
			
			self.checkIdentityView.alpha = 1
		} completion: { [weak self] _ in
			
			UIAccessibility.post(notification: .screenChanged, argument: self?.checkIdentityView)
		}
	}
	
	@objc func readMoreTapped() {
		
		readMoreTappedCommand?()
	}
}

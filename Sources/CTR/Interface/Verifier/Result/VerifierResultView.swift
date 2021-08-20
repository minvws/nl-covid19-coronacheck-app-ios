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
	private enum ViewTraits {

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
	
	private var accessView: AccessView?

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
				setup(view: view)
				revealIdentityView(for: result)
				accessView = view
			case .demo:
				let view = VerifiedView()
				view.backgroundColor = result.colors
				setup(view: view)
				revealIdentityView(for: result)
				accessView = view
			case .denied:
				let view = DeniedView()
				view.footerButtonView.primaryButtonTappedCommand = { [weak self] in self?.scanNextTappedCommand?() }
				view.secondaryButton.touchUpInside(self, action: #selector(readMoreTapped))
				setup(view: view)
				accessView = view
		}
	}
	
	// MARK: - Public
	
	var title: String? {
		didSet {
			accessView?.title(title)
		}
	}
	
	var primaryTitle: String? {
		didSet {
			accessView?.primaryTitle(primaryTitle)
			checkIdentityView.primaryTitle = primaryTitle
		}
	}
	
	var secondaryTitle: String? {
		didSet {
			accessView?.secondaryTitle(secondaryTitle)
			checkIdentityView.secondaryTitle = secondaryTitle
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
		checkIdentityView.footerButtonView.primaryButtonTappedCommand = { [weak self] in self?.scanNextTappedCommand?() }
		checkIdentityView.secondaryButton.touchUpInside(self, action: #selector(readMoreTapped))
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

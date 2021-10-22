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

	let checkIdentityView: VerifierCheckIdentityView = {

		let view = VerifierCheckIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let verifiedView = VerifiedView()
	
	private var accessView: AccessView?

	/// Setup the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	func setup(for result: Result) {
		switch result {
			case .verified, .demo:
				setupViews(for: result)
			case .denied:
				let view = DeniedView()
				view.footerButtonView.primaryButtonTappedCommand = { [weak self] in self?.scanNextTappedCommand?() }
				view.secondaryButton.touchUpInside(self, action: #selector(readMoreTapped))
				view.embed(in: self)
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
	
	var primaryButtonIcon: UIImage? {
		didSet {
			checkIdentityView.footerButtonView.primaryButton.setImage(primaryButtonIcon, for: .normal)
		}
	}
	
	/// The user tapped on the primary button
	var scanNextTappedCommand: (() -> Void)?
	
	/// The user tapped on the secondary button in the denied view
	var readMoreTappedCommand: (() -> Void)?
	
	/// The user tapped on the secondary button in the verified view
	var verifiedInfoTappedCommand: (() -> Void)?
}

private extension VerifierResultView {
	
	func setupViews(for result: Result) {
		
		verifiedView.backgroundColor = result.colors
		accessView = verifiedView
		
		checkIdentityView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			self?.displayVerifiedView()
			self?.verifiedInfoTappedCommand?()
		}
		checkIdentityView.secondaryButton.touchUpInside(self, action: #selector(readMoreTapped))
		checkIdentityView.embed(in: self)
	}
	
	func displayVerifiedView() {
		
		verifiedView.alpha = 0
		verifiedView.embed(in: self)
		
		UIView.animate(withDuration: VerifierResultViewTraits.Animation.verifiedDuration) {
			self.verifiedView.alpha = 1
		}
	}
	
	@objc func readMoreTapped() {
		
		readMoreTappedCommand?()
	}
}

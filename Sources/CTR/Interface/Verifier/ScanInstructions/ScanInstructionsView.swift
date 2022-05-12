/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanInstructionsView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let buttonHeight: CGFloat = 52
		
		// Margins
		static let margin: CGFloat = 20.0
		static let pageControlSpacing: CGFloat = 16.0
		static let pageControlSpacingSmallScreen: CGFloat = 8.0
	}

	/// The container for the the onboarding views
	let containerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The control buttons
	let pageControl: PageControl = {

		let view = PageControl()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	/// the update button
	var primaryButton: Button {
		return footerButtonView.primaryButton
	}
	
	/// Footer view with primary button
	let footerButtonView: FooterButtonView = {
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		footerView.buttonStackView.alignment = .center
		footerView.buttonStackView.spacing = UIDevice.current.isSmallScreen ? ViewTraits.pageControlSpacingSmallScreen : ViewTraits.pageControlSpacing
		footerView.topButtonConstraint?.constant = 0
		return footerView
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = C.white()
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(containerView)
		addSubview(footerButtonView)
		footerButtonView.buttonStackView.insertArrangedSubview(pageControl, at: 0)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
			containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
			
			footerButtonView.topAnchor.constraint(equalTo: containerView.bottomAnchor),
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
	}

	// MARK: - Public Access
	
	/// Updates `FooterButtonView` shadow separator
	/// - Parameter mainScrollView: Main scroll view to observe content offset
	func updateFooterView(mainScrollView: UIScrollView) {
		scrollViewContentOffsetObserver?.invalidate()
		scrollViewContentOffsetObserver = mainScrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}
}

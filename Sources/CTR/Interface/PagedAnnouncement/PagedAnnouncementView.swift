/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PagedAnnouncementView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Margins
		static let ribbonOffset: CGFloat = 15.0
		static let pageControlSpacing: CGFloat = 16.0
		static let pageControlSpacingSmallScreen: CGFloat = 8.0
	}

	/// The government ribbon
	let ribbonView: UIImageView = {
		
		let view = UIImageView(image: I.onboarding.rijkslint())
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

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
		return footerView
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	let shouldShowWithVWSRibbon: Bool
	
	init(shouldShowWithVWSRibbon: Bool) {
		self.shouldShowWithVWSRibbon = shouldShowWithVWSRibbon
		super.init(frame: .zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
 
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = C.white()
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		if shouldShowWithVWSRibbon {
			addSubview(ribbonView)
		}
		addSubview(containerView)
		addSubview(footerButtonView)
		footerButtonView.buttonStackView.insertArrangedSubview(pageControl, at: 0)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		if shouldShowWithVWSRibbon {
			NSLayoutConstraint.activate([
				ribbonView.centerXAnchor.constraint(equalTo: centerXAnchor),
				ribbonView.topAnchor.constraint(
					equalTo: topAnchor,
					constant: UIDevice.current.hasNotch ? 0 : -ViewTraits.ribbonOffset
				)
			])
		}
		
		NSLayoutConstraint.activate([
			// ImageContainer
			containerView.topAnchor.constraint(equalTo: shouldShowWithVWSRibbon ? ribbonView.bottomAnchor : topAnchor),
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
		
		if shouldShowWithVWSRibbon {
			// Ribbon view
			ribbonView.isAccessibilityElement = true
			ribbonView.accessibilityLabel = L.generalGovernmentLogo()
		}
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

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class NewFeaturesView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		// Dimensions
		static let buttonHeight: CGFloat = 52
		
		// Margins
		static let margin: CGFloat = 20.0
		static let pageControlMargin: CGFloat = 12.0
	}
	
	/// The container for the the onboarding views
	let containerView: UIView = {

		let view = UIView()
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
		return footerView
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(containerView)
		addSubview(footerButtonView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([

			// ImageContainer
			containerView.topAnchor.constraint(equalTo: topAnchor),
			containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
			
			footerButtonView.topAnchor.constraint(equalTo: containerView.bottomAnchor),
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
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

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let buttonHeight: CGFloat = 52
		
		// Margins
		static let margin: CGFloat = 20.0
		static let ribbonOffset: CGFloat = 15.0
		static let buttonWidth: CGFloat = 182.0
		static let pageControlMargin: CGFloat = 12.0
	}

	/// The government ribbon
	private let ribbonView: UIImageView = {
		
		let view = UIImageView(image: .ribbon)
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
	let pageControl: UIPageControl = {
		
		let view = UIPageControl()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.pageIndicatorTintColor = Theme.colors.gray.withAlphaComponent(0.3)
		view.currentPageIndicatorTintColor = Theme.colors.gray
		return view
	}()
	
	/// the update button
	let primaryButton: Button = {
		
		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(ribbonView)
		addSubview(containerView)
		addSubview(pageControl)
		addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			// Ribbon
			ribbonView.centerXAnchor.constraint(equalTo: centerXAnchor),
			ribbonView.topAnchor.constraint(
				equalTo: topAnchor,
				constant: UIDevice.current.hasNotch ? 0 : -ViewTraits.ribbonOffset
			),

			// ImageContainer
			containerView.topAnchor.constraint(equalTo: ribbonView.bottomAnchor),
			containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

			// Button
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonWidth),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	override func layoutSubviews() {
		
		super.layoutSubviews()

		// Layout page control when the view has a frame
		NSLayoutConstraint.activate([

			// Message
			containerView.bottomAnchor.constraint(
				equalTo: pageControl.topAnchor,
				constant: UIDevice.current.isSmallScreen ? 0 : -ViewTraits.margin
			),

			// Page Control
			pageControl.bottomAnchor.constraint(
				equalTo: primaryButton.topAnchor,
				constant: UIDevice.current.isSmallScreen ? 0 : -ViewTraits.pageControlMargin),
			pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
	let primaryButton = Button()
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(containerView)
		addSubview(pageControl)
		addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
			containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
			
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.leadingAnchor.constraint(
				greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			),
			primaryButton.trailingAnchor.constraint(
				lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.margin
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}
	
	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
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
				constant: UIDevice.current.isSmallScreen ? -ViewTraits.pageControlSpacingSmallScreen : -ViewTraits.pageControlSpacing),
			pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
}

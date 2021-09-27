/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class ForcedInformationView: BaseView {
	
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
		addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([

			// ImageContainer
			containerView.topAnchor.constraint(equalTo: topAnchor),
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
}

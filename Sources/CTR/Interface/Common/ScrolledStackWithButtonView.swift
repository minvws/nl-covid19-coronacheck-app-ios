/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScrolledStackWithButtonView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let buttonWidth: CGFloat = 212.0
		static let spacing: CGFloat = 24.0

		// Margins
		static let margin: CGFloat = 20.0
	}

	/// the update button
	var primaryButton: Button {
		return footerButtonView.primaryButton
	}
	
	/// The footer view with primary button
	let footerButtonView: FooterButtonView = {
		
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		stackView.spacing = ViewTraits.spacing
		view?.backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let adjustedOffset = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.bounds.height)
			self?.footerButtonView.updateFadeAnimation(from: adjustedOffset)
		}
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(footerButtonView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		bottomScrollViewConstraint?.isActive = false

		NSLayoutConstraint.activate([
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

//	func setupPrimaryButton(useFullWidth: Bool = false) {
//
//		NSLayoutConstraint.activate([
//
//			// Primary button
//			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
//			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor)
//		])
//		primaryButton.setContentHuggingPriority(.required, for: .vertical)
//
//		if useFullWidth {
//			NSLayoutConstraint.activate([
//
//				primaryButton.leadingAnchor.constraint(
//					equalTo: safeAreaLayoutGuide.leadingAnchor,
//					constant: ViewTraits.buttonMargin
//				),
//				primaryButton.trailingAnchor.constraint(
//					equalTo: safeAreaLayoutGuide.trailingAnchor,
//					constant: -ViewTraits.buttonMargin
//				)
//			])
//		} else {
//			NSLayoutConstraint.activate([
//
//				primaryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonWidth),
//				primaryButton.leadingAnchor.constraint(
//					greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor,
//					constant: ViewTraits.buttonMargin
//				),
//				primaryButton.trailingAnchor.constraint(
//					lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor,
//					constant: -ViewTraits.buttonMargin
//				)
//			])
//		}
//
//		topButtonConstraint = primaryButton.topAnchor.constraint(equalTo: footerBackground.topAnchor)
//		topButtonConstraint?.isActive = true
//
//		bottomButtonConstraint = primaryButton.bottomAnchor.constraint(
//			equalTo: safeAreaLayoutGuide.bottomAnchor,
//			constant: -ViewTraits.margin
//		)
//		bottomButtonConstraint?.isActive = true
//	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title for the primary button
	var primaryTitle: String? {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// bottom constraint for keyboard changes.
	// Update
	var bottomButtonConstraint: NSLayoutConstraint?
}

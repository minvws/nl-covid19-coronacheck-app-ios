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
		static let gradientHeight: CGFloat = 15.0
		static let spacing: CGFloat = 24.0

		// Margins
		static let margin: CGFloat = 20.0
	}

	/// the footer background
	private let footerBackground: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()

	/// The footer gradient
	private let footerGradientView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// the update button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	/// bottom contraint for keyboard changes.
	var bottomConstraint: NSLayoutConstraint?

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		stackView.spacing = ViewTraits.spacing
		view?.backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(footerGradientView)
		footerBackground.addSubview(primaryButton)
		addSubview(footerBackground)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Footer background
			footerGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerGradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerGradientView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor),
			footerGradientView.heightAnchor.constraint(equalToConstant: ViewTraits.gradientHeight),

			// Footer background
			footerBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerBackground.bottomAnchor.constraint(equalTo: bottomAnchor),

			// Primary button
			primaryButton.topAnchor.constraint(equalTo: footerBackground.topAnchor),
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonWidth)
		])

		bottomConstraint = primaryButton.bottomAnchor.constraint(
			equalTo: safeAreaLayoutGuide.bottomAnchor,
			constant: -ViewTraits.margin
		)
		bottomConstraint?.isActive = true
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	/// Setup the gradient in the footer
	private func setFooterGradient() {

		footerGradientView.backgroundColor = .clear
		let gradient = CAGradientLayer()
		gradient.frame = footerGradientView.bounds
		gradient.colors = [
			Theme.colors.viewControllerBackground.withAlphaComponent(0.0).cgColor,
			Theme.colors.viewControllerBackground.withAlphaComponent(0.5).cgColor,
			Theme.colors.viewControllerBackground.withAlphaComponent(1.0).cgColor
		]
		footerGradientView.layer.insertSublayer(gradient, at: 0)
	}

	override func layoutSubviews() {

		super.layoutSubviews()

		setFooterGradient()
	}

	// MARK: Public Access

	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}

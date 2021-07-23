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
		static let buttonMargin: CGFloat = 36.0
	}

	/// The line above the button
	let lineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.line
		return view
	}()

	/// the footer background
	let footerBackground: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The footer gradient
	let footerGradientView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// the update button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		button.titleLabel?.textAlignment = .center
		return button
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		stackView.spacing = ViewTraits.spacing
		view?.backgroundColor = actionColor
		footerBackground.backgroundColor = actionColor
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(lineView)
		addSubview(footerGradientView)
		footerBackground.addSubview(primaryButton)
		addSubview(footerBackground)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Line
			lineView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor),
			lineView.heightAnchor.constraint(equalToConstant: 1),

			// Footer background
			footerGradientView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			footerGradientView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			footerGradientView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor),
			footerGradientView.heightAnchor.constraint(equalToConstant: ViewTraits.gradientHeight),

			// Footer background
			footerBackground.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			footerBackground.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			footerBackground.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	func setupPrimaryButton(useFullWidth: Bool = false) {

		NSLayoutConstraint.activate([

			// Primary button
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
		primaryButton.setContentHuggingPriority(.required, for: .vertical)

		if useFullWidth {
			NSLayoutConstraint.activate([

				primaryButton.leadingAnchor.constraint(
					equalTo: safeAreaLayoutGuide.leadingAnchor,
					constant: ViewTraits.buttonMargin
				),
				primaryButton.trailingAnchor.constraint(
					equalTo: safeAreaLayoutGuide.trailingAnchor,
					constant: -ViewTraits.buttonMargin
				)
			])
		} else {
			NSLayoutConstraint.activate([

				primaryButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonWidth)
			])
		}

		topButtonConstraint = primaryButton.topAnchor.constraint(equalTo: footerBackground.topAnchor)
		topButtonConstraint?.isActive = true

		bottomButtonConstraint = primaryButton.bottomAnchor.constraint(
			equalTo: safeAreaLayoutGuide.bottomAnchor,
			constant: -ViewTraits.margin
		)
		bottomButtonConstraint?.isActive = true
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
			footerActionColor.withAlphaComponent(0.0).cgColor,
			footerActionColor.withAlphaComponent(0.5).cgColor,
			footerActionColor.withAlphaComponent(1.0).cgColor
		]
		footerGradientView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
		footerGradientView.layer.insertSublayer(gradient, at: 0)
	}

	override func layoutSubviews() {

		super.layoutSubviews()
		setFooterGradient()
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
	var bottomButtonConstraint: NSLayoutConstraint?

	/// top constraint for keyboard changes.
	var topButtonConstraint: NSLayoutConstraint?

	/// The color to use for the backgrounds and gradient. Defaults to Theme.colors.viewControllerBackground
	var actionColor: UIColor = Theme.colors.viewControllerBackground {
		didSet {
			backgroundColor = actionColor
		}
	}

	/// The color to use for the backgrounds and gradient. Defaults to Theme.colors.viewControllerBackground
	var footerActionColor: UIColor = Theme.colors.viewControllerBackground {
		didSet {
			setFooterGradient()
			footerBackground.backgroundColor = footerActionColor
		}
	}

	/// Show the line view and hide the gradient. 
	var showLineView: Bool = false {
		didSet {
			footerGradientView.isHidden = showLineView
			lineView.isHidden = !showLineView
		}
	}
}

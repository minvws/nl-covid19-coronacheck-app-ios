/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListResultsView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22
		static let imageRatio: CGFloat = 0.75
		static let gradientHeight: CGFloat = 30.0

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 54.0
		static let titleTopMargin: CGFloat = 34.0
		static let messageTopMargin: CGFloat = 24.0
	}

	/// The title label
	let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// the update button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	let resultView: ListResultView = {

		let view = ListResultView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	private let spacer: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()

	private let footerBackground: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()

	let footerGradientView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(resultView)
		stackView.addArrangedSubview(spacer)
		addSubview(footerGradientView)
		footerBackground.addSubview(primaryButton)
		addSubview(footerBackground)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Spacer
			spacer.heightAnchor.constraint(equalToConstant: 2 * ViewTraits.buttonHeight),

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
			primaryButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			primaryButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
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
		// Title
		titleLabel.accessibilityTraits = .header
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	private func setFooterGradient() {

		footerGradientView.backgroundColor = .clear
		let gradient = CAGradientLayer()
		gradient.frame = footerGradientView.bounds
		gradient.colors = [
			Theme.colors.viewControllerBackground.withAlphaComponent(0.0).cgColor,
			Theme.colors.viewControllerBackground.withAlphaComponent(0.5).cgColor,
			Theme.colors.viewControllerBackground.withAlphaComponent(1.0).cgColor
		]
		footerGradientView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
		footerGradientView.layer.insertSublayer(gradient, at: 0)
	}

	override func layoutSubviews() {

		super.layoutSubviews()

		setFooterGradient()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}

	/// The message
	var message: String? {
		didSet {
//			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
			messageLabel.attributedText = .makeFromHtml(text: message, font: Theme.fonts.body, textColor: Theme.colors.dark)
		}
	}

	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ForcedInformationConsentView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 10.0
//		static let shadowRadius: CGFloat = 6
//		static let shadowOpacity: Float = 0.2
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 26
//		static let messageLineHeight: CGFloat = 22
//		static let gradientHeight: CGFloat = 15.0
		static let buttonWidth: CGFloat = 182.0
//
//		// Margins
		static let margin: CGFloat = 20.0
		static let bottomMargin: CGFloat = 8.0
		static let spacing: CGFloat = 24.0
	}

	/// The scrollview
	let scrollView: UIScrollView = {

		let view = UIScrollView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stackview for the content
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .equalSpacing
		view.spacing = ViewTraits.spacing
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()

	private let highlightView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.highlightBackgroundColor
		view.layer.cornerRadius = ViewTraits.cornerRadius
		return view
	}()

	/// The highlight label
	private let hightlightLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The content label
	private let contentLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// the primart button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	/// the secondary button
	let secondaryButton: Button = {

		let button = Button(title: "Button 2", style: .tertiary)
		button.titleLabel?.font = Theme.fonts.bodySemiBold
		button.isHidden = true
		return button
	}()

	let lineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.line
		view.isHidden = true
		return view
	}()

	var primaryButtonToBottomConstraint: NSLayoutConstraint?
	var primaryButtonToSecondaryButtonConstraint: NSLayoutConstraint?

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		hightlightLabel.embed(
			in: highlightView,
			insets: UIEdgeInsets(
				top: ViewTraits.margin,
				left: ViewTraits.margin,
				bottom: ViewTraits.margin,
				right: ViewTraits.margin
			)
		)

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(highlightView)
		stackView.addArrangedSubview(contentLabel)

		scrollView.addSubview(stackView)

		addSubview(scrollView)
		addSubview(lineView)
		addSubview(primaryButton)
		addSubview(secondaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Scrollview
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(
				equalTo: primaryButton.topAnchor,
				constant: -ViewTraits.bottomMargin
			),

			// StackView
			stackView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2.0 * ViewTraits.margin
			),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			stackView.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: ViewTraits.margin
			),
			stackView.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			),

			// Line
			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			lineView.bottomAnchor.constraint(
				equalTo: primaryButton.topAnchor,
				constant: -ViewTraits.bottomMargin
			),
			lineView.heightAnchor.constraint(equalToConstant: 1),

			// Primary Button
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonWidth),

			secondaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			secondaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			secondaryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonWidth),
			secondaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])

		// Default enabled, the primary button to the bottom of the view
		primaryButtonToBottomConstraint = primaryButton.bottomAnchor.constraint(
			equalTo: safeAreaLayoutGuide.bottomAnchor,
			constant: -ViewTraits.margin
		)
		primaryButtonToBottomConstraint?.isActive = true

		// Default disabled, the primary button to the top of the secondary button
		primaryButtonToSecondaryButtonConstraint = primaryButton.bottomAnchor.constraint(equalTo: secondaryButton.topAnchor)
		primaryButtonToSecondaryButtonConstraint?.isActive = false

	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
		// Title
		titleLabel.accessibilityTraits = .header
	}

	// MARK: - Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The highlight
	var highlight: String? {
		didSet {
			hightlightLabel.attributedText = .makeFromHtml(
				text: highlight,
				font: Theme.fonts.body,
				textColor: Theme.colors.dark
			)
		}
	}

	/// The content
	var content: String? {
		didSet {
			contentLabel.attributedText = .makeFromHtml(
				text: content,
				font: Theme.fonts.body,
				textColor: Theme.colors.dark
			)
		}
	}

	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	var secondaryTitle: String = "" {
		didSet {
			if secondaryTitle.isEmpty {
				secondaryButton.isHidden = true
				primaryButtonToBottomConstraint?.isActive = true
			} else {
				secondaryButton.setTitle(secondaryTitle, for: .normal)
				secondaryButton.isHidden = false
				primaryButtonToBottomConstraint?.isActive = false
				primaryButtonToSecondaryButtonConstraint?.isActive = true
				setNeedsLayout()
			}
		}
	}
}

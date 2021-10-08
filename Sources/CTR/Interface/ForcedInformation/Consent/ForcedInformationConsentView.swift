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
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 26
		static let buttonWidth: CGFloat = 182.0

		// Margins
		static let margin: CGFloat = 20.0
		static let bottomMargin: CGFloat = 32.0
		static let spacing: CGFloat = 24.0
		static let contentSpacing: CGFloat = 40.0
		static let singleButtonBottomMargin: CGFloat = UIDevice.current.hasNotch ? 10 : 32
	}

	/// The scrollview
	let scrollView: UIScrollView = {

		let view = UIScrollView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stack view for the content
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

        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	/// The view containing the highlight
	private let highlightView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.highlightBackgroundColor
		view.layer.cornerRadius = ViewTraits.cornerRadius
		return view
	}()

	private let highlightTextView: TextView = {

		return TextView()
	}()

	let contentTextView: TextView = {

		return TextView()
	}()

	let primaryButton = Button()

	/// the secondary button
	let secondaryButton: Button = {

		let button = Button(title: "Button 2", style: .textLabelBlue)
		button.isHidden = true
		return button
	}()

	/// The line above the buttons
	let lineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.line
		return view
	}()

	var primaryButtonToBottomConstraint: NSLayoutConstraint?
	var primaryButtonToSecondaryButtonConstraint: NSLayoutConstraint?

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground

		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		highlightTextView.embed(
			in: highlightView,
			insets: UIEdgeInsets.all(ViewTraits.margin)
		)

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(highlightView)
		stackView.setCustomSpacing(ViewTraits.contentSpacing, after: highlightView)
		stackView.addArrangedSubview(contentTextView)

		stackView.embed(
			in: scrollView,
			insets: UIEdgeInsets.all(ViewTraits.margin)
		)

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
			primaryButton.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),

			// Secondary Button
			secondaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight),
			secondaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			secondaryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonWidth),
			secondaryButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
		])

		// Default enabled, the primary button to the bottom of the view
		primaryButtonToBottomConstraint = primaryButton.bottomAnchor.constraint(
			equalTo: safeAreaLayoutGuide.bottomAnchor,
			constant: -ViewTraits.singleButtonBottomMargin
		)
		primaryButtonToBottomConstraint?.isActive = true

		// Default disabled, the primary button to the top of the secondary button
		primaryButtonToSecondaryButtonConstraint = primaryButton.bottomAnchor.constraint(equalTo: secondaryButton.topAnchor)
		primaryButtonToSecondaryButtonConstraint?.isActive = false
	}

	// MARK: - Interaction

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	/// User tapped on the primary button
	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
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
			highlightTextView.attributedText = .makeFromHtml(text: highlight, style: .bodyDark)
		}
	}

	/// The content
	var content: String? {
		didSet {
			contentTextView.html(content)
		}
	}

	/// The title for the primary button
	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The title for the secondary button
	var secondaryTitle: String? {
		didSet {
			secondaryButton.setTitle(secondaryTitle, for: .normal)
		}
	}

	/// Show the secondary button
	func showSecondaryButton() {

		secondaryButton.isHidden = false
		primaryButtonToBottomConstraint?.isActive = false
		primaryButtonToSecondaryButtonConstraint?.isActive = true
		setNeedsLayout()
	}

	/// Hide the secondary button
	func hideSecondaryButton() {

		secondaryButton.isHidden = true
		primaryButtonToBottomConstraint?.isActive = true
		setNeedsLayout()
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// The user tapped on the secondary button
	var secondaryButtonTappedCommand: (() -> Void)?
}

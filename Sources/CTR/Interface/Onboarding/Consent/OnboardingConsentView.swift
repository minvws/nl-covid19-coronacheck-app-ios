/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class OnboardingConsentView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let shadowRadius: CGFloat = 6
		static let shadowOpacity: Float = 0.2
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22
		static let gradientHeight: CGFloat = 15.0
		static let buttonWidth: CGFloat = 182.0

		// Margins
		static let margin: CGFloat = 20.0
		static let bottomMargin: CGFloat = 8.0
		static let itemSpacing: CGFloat = 24.0
		static let iconToLabelSpacing: CGFloat = 16.0
	}

	/// The scrollview
	let scrollView: ScrolledContentHeightView = {

		let view = ScrolledContentHeightView()
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
		view.spacing = ViewTraits.margin
		return view
	}()

	/// The stack view for the privacy highlight items
	let itemStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.itemSpacing
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// the update button
	let primaryButton = Button()

	let lineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.line
		view.isHidden = true
		return view
	}()

	let consentButton: ConsentButton = {

		let button = ConsentButton()
		button.translatesAutoresizingMaskIntoConstraints = false
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

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(itemStackView)
		scrollView.contentView.addSubview(stackView)
		scrollView.contentView.addSubview(consentButton)

		addSubview(scrollView)
		addSubview(lineView)
		addSubview(primaryButton)
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
			stackView.topAnchor.constraint(
				equalTo: scrollView.contentView.topAnchor,
				constant: ViewTraits.margin
			),
			stackView.leftAnchor.constraint(
				equalTo: scrollView.contentView.leftAnchor,
				constant: ViewTraits.margin
			),
			stackView.rightAnchor.constraint(
				equalTo: scrollView.contentView.rightAnchor,
				constant: -ViewTraits.margin
			),
			stackView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2.0 * ViewTraits.margin
			),
			stackView.centerXAnchor.constraint(equalTo: scrollView.contentView.centerXAnchor),
			
			// Consent button
			consentButton.topAnchor.constraint(
				greaterThanOrEqualTo: stackView.bottomAnchor,
				constant: ViewTraits.itemSpacing
			),
			consentButton.leftAnchor.constraint(
				equalTo: scrollView.contentView.leftAnchor,
				constant: ViewTraits.margin
			),
			consentButton.rightAnchor.constraint(
				equalTo: scrollView.contentView.rightAnchor,
				constant: -ViewTraits.margin
			),
			consentButton.bottomAnchor.constraint(
				equalTo: scrollView.contentView.bottomAnchor,
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
			primaryButton.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	// MARK: - Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}

	/// Underline part ot the message
	/// - Parameter text: the text to underline
	func underline(_ text: String?) {

		guard let underlinedText = text,
			  let messageText = message else {
			return
		}

		let attributedUnderlined = messageText.underlineAsLink(underlined: underlinedText)
		messageLabel.attributedText = attributedUnderlined.setLineHeight(ViewTraits.messageLineHeight)
		messageLabel.accessibilityTraits = [.staticText, .link]
	}

	var consent: String? {
		didSet {
			consentButton.setTitle(consent, for: .normal)
		}
	}

	/// Add a privacy item
	/// - Parameter text: the privacy text
	func addPrivacyItem(_ text: String, number: Int, total: Int) {

        let textView = TextView(htmlText: text)
		var accessibiliyHint = ""
		if number == 1 {
			accessibiliyHint = L.generalListAccessibilityStart()
		}
		accessibiliyHint += L.generalListAccessibility("\(number)", "\(total)")
		if number == total {
			accessibiliyHint += L.generalListAccessibilityEnd()
		}
		textView.accessibilityHint = accessibiliyHint
		
		let imageView = ImageView(imageName: I.onboarding.privacyItem.name).asIcon()
		imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		let stack = HStack(
			spacing: ViewTraits.iconToLabelSpacing,
			imageView,
			textView
		)
		.alignment(.center)
		itemStackView.addArrangedSubview(stack)
	}
}

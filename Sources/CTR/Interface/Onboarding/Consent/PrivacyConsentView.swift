/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PrivacyConsentView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let maxButtonHeightMultiplier: CGFloat = 0.3

		// Margins
		static let margin: CGFloat = 20.0
		static let itemSpacing: CGFloat = 24.0
		static let iconToLabelSpacing: CGFloat = 16.0
		static let consentButtonToErrorSpacing: CGFloat = 5.0
		static let errorViewMargin: CGFloat = 8.0
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
	
	/// Footer view with primary button
	let footerButtonView: FooterButtonView = {
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	/// the update button
	var primaryButton: Button {
		return footerButtonView.primaryButton
	}

	let consentButton: LabelWithCheckbox = {

		let button = LabelWithCheckbox()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.defaultBackgroundColor = C.primaryBlue5()
		return button
	}()
	
	let errorView: ErrorView = {
		
		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextView)
		stackView.addArrangedSubview(itemStackView)
		scrollView.contentView.addSubview(stackView)

		addSubview(scrollView)
		addSubview(footerButtonView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Scrollview
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: footerButtonView.topAnchor),

			// StackView
			stackView.topAnchor.constraint(
				equalTo: scrollView.contentView.topAnchor,
				constant: ViewTraits.margin
			),
			stackView.leadingAnchor.constraint(
				equalTo: scrollView.contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: scrollView.contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			stackView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2.0 * ViewTraits.margin
			),
			stackView.centerXAnchor.constraint(equalTo: scrollView.contentView.centerXAnchor),
			stackView.bottomAnchor.constraint(
				lessThanOrEqualTo: scrollView.contentView.bottomAnchor,
				constant: -ViewTraits.margin
			),

			// Footer view
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
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
			NSAttributedString.makeFromHtml(
				text: message,
				style: .bodyDark
			) {
				self.contentTextView.attributedText = $0
			}
		}
	}

	var consent: String? {
		didSet {
			consentButton.title = consent
		}
	}
	
	var consentError: String? {
		didSet {
			errorView.error = consentError
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
	
	/// Setup the consent button. By default hidden.
	func setupConsentButton() {
		
		footerButtonView.buttonStackView.alignment = .center
		
		footerButtonView.buttonStackView.insertArrangedSubview(consentButton, at: 0)
		footerButtonView.buttonStackView.insertArrangedSubview(errorView, at: 1)
		
		NSLayoutConstraint.activate([
			errorView.widthAnchor.constraint(
				equalTo: consentButton.widthAnchor,
				constant: -2 * ViewTraits.errorViewMargin
			),
			// Buttons have a maximum height for large font size
			consentButton.heightAnchor.constraint(
				lessThanOrEqualTo: safeAreaLayoutGuide.heightAnchor,
				multiplier: ViewTraits.maxButtonHeightMultiplier
			),
			primaryButton.heightAnchor.constraint(
				lessThanOrEqualTo: safeAreaLayoutGuide.heightAnchor,
				multiplier: ViewTraits.maxButtonHeightMultiplier
			)
		])
	}
	
	var hasErrorState: Bool? {
		didSet {
			guard let hasError = hasErrorState else { return }
			consentButton.hasError = hasError
			errorView.isHidden = !hasError
			
			let spacing = hasError ? ViewTraits.consentButtonToErrorSpacing : footerButtonView.buttonStackView.spacing
			footerButtonView.buttonStackView.setCustomSpacing(spacing, after: consentButton)
		}
	}
}

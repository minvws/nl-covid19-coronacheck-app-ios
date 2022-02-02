/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Lottie

class VerifierStartView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22

		// Margins
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 16.0
		static let titleTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 34.0
		static let messageTopMargin: CGFloat = 24.0
	}
	
	enum HeaderMode: Equatable {
		case image(_: UIImage)
		case animation(_: String)
		
		var isImage: Bool {
			switch self {
				case .image: return true
				case .animation: return false
			}
		}
		
		var isAnimation: Bool {
			switch self {
				case .image: return false
				case .animation: return true
			}
		}
	}

	/// Scroll view bottom constraint
	private var bottomScrollViewConstraint: NSLayoutConstraint?

	private let scrollView: UIScrollView = {

		let view = UIScrollView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stackView for the content
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .center
		view.distribution = .fill
		view.spacing = 0
		return view
	}()

	private let contentView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()

	private let headerStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	private let headerImageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		view.contentMode = .center
		return view
	}()
	
	private let headerAnimationView: AnimationView = {
		
		let view = AnimationView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		view.contentMode = .scaleAspectFit
		view.respectAnimationFrameRate = true
		view.backgroundBehavior = .pauseAndRestore
		view.loopMode = .loop
		return view
	}()
	
	private let fakeNavigationBar: FakeNavigationBarView = {
		let navbar = FakeNavigationBarView()
		navbar.translatesAutoresizingMaskIntoConstraints = false
		return navbar
	}()

	private let titleLabel: Label = {

        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	private let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let showInstructionsButton: Button = {

		let button = Button(title: "Button 2", style: .textLabelBlue)
		button.titleLabel?.font = Theme.fonts.bodyMedium
		button.contentHorizontalAlignment = .leading
		return button
	}()

	/// Footer view with primary button
	private let footerButtonView: FooterButtonView = {
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		footerView.buttonStackView.alignment = .center
		return footerView
	}()

	let clockDeviationWarningView: VerifierClockDeviationWarningView = {
		let view = VerifierClockDeviationWarningView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	private let riskIndicatorStackView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .horizontal
		view.spacing = 8 // ViewTraits.Spacing.aboveButton
		return view
	}()

	private let riskIndicatorIconView: RiskIndicatorIconView = {
		let view = RiskIndicatorIconView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let riskIndicatorLabel: Label = {
		let label = Label(subhead: "")
		return label
	}()

	private var scrollViewContentOffsetObserver: NSKeyValueObservation?

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		
		footerButtonView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		showInstructionsButton.touchUpInside(self, action: #selector(showInstructionsButtonTapped))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(headerStackView)
		headerStackView.addArrangedSubview(headerImageView)
		headerStackView.addArrangedSubview(headerAnimationView)
		
		stackView.addArrangedSubview(contentView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(contentTextView)
		contentView.addSubview(showInstructionsButton)

		scrollView.addSubview(stackView)
		addSubview(scrollView)

		addSubview(fakeNavigationBar)
		addSubview(clockDeviationWarningView)
		addSubview(footerButtonView)
		
		footerButtonView.buttonStackView.insertArrangedSubview(riskIndicatorStackView, at: 0)

		riskIndicatorStackView.addArrangedSubview(riskIndicatorIconView)
		riskIndicatorStackView.addArrangedSubview(riskIndicatorLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		// Setup ScrollView & StackView:
		
		NSLayoutConstraint.activate([

			fakeNavigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			fakeNavigationBar.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			fakeNavigationBar.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),

			// Scrollview
			scrollView.topAnchor.constraint(equalTo: fakeNavigationBar.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			{
				let constraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
				bottomScrollViewConstraint = constraint
				return constraint
			}(),

			// Outer StackView
			stackView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			stackView.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: ViewTraits.topMargin
			),
			stackView.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			),
			stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

			contentView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
		])
		
		// Setup content views:
		bottomScrollViewConstraint?.isActive = false

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: headerStackView.bottomAnchor,
				constant: ViewTraits.titleTopMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: contentTextView.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Content
			contentTextView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			contentTextView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			showInstructionsButton.centerXAnchor.constraint(
				equalTo: contentView.centerXAnchor
			),
			showInstructionsButton.topAnchor.constraint(
				equalTo: contentTextView.bottomAnchor,
				constant: ViewTraits.margin
			),
			showInstructionsButton.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			showInstructionsButton.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			showInstructionsButton.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -ViewTraits.margin
			),

			// Footer view
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),

			// ClockDeviationWarningView
			clockDeviationWarningView.topAnchor.constraint(equalTo: fakeNavigationBar.bottomAnchor),
			clockDeviationWarningView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: ViewTraits.margin),
			clockDeviationWarningView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -ViewTraits.margin),
			
			riskIndicatorIconView.heightAnchor.constraint(equalTo: riskIndicatorLabel.heightAnchor),
			riskIndicatorIconView.heightAnchor.constraint(equalTo: riskIndicatorIconView.widthAnchor)
		])
	}
	
	override func setupAccessibility() {
		super.setupAccessibility()
		
		titleLabel.accessibilityTraits.insert(.updatesFrequently)
	}
	
	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	/// User tapped on the showInstructions button
	@objc func showInstructionsButtonTapped() {

		showInstructionsButtonTappedCommand?()
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
			// Due to TextView rendering issue, check attributedText directly for old value.
			// This prevents VoiceOver unable to focus on other subviews.
			guard contentTextView.attributedText?.string != message else { return }
			contentTextView.html(message)
		}
	}

	/// The title of the primary button
	var primaryTitle: String = "" {
		didSet {
			footerButtonView.primaryButton.title = primaryTitle
		}
	}

	/// The title of the showInstructions Button
	var showInstructionsTitle: String? {
		didSet {
			showInstructionsButton.title = showInstructionsTitle
		}
	}
	
	var showsPrimaryButton: Bool = true {
		didSet {
			footerButtonView.primaryButton.isHidden = !showsPrimaryButton
		}
	}
	
	var showsInstructionsButton: Bool = true {
		didSet {
			showInstructionsButton.isHidden = !showsInstructionsButton
		}
	}
	
	func setRiskIndicator(params: (UIColor, String)?) {
		guard let params = params else {
			riskIndicatorStackView.isHidden = true
			return
		}
		riskIndicatorStackView.isHidden = false
		riskIndicatorIconView.tintColor = params.0
		riskIndicatorLabel.attributedText = .makeFromHtml(
			text: params.1,
			style: .bodyDark
		)
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// The user tapped on the showInstructions button
	var showInstructionsButtonTappedCommand: (() -> Void)?

	var headerMode: HeaderMode? {
		didSet {
			updateHeaderModeVisibility()

			guard oldValue != headerMode else { return }
			switch headerMode {
				case .animation(let animationName):
					headerAnimationView.animation = Lottie.Animation.named(animationName)
					headerAnimationView.play()
				case .image(let image):
					headerImageView.image = image
				case .none:
					headerImageView.image = nil
					headerAnimationView.animation = nil
			}
		}
	}
	
	/// Will make the correct view visible for current headerMode
	private func updateHeaderModeVisibility() {
		guard !shouldKeepHeaderHidden, let headerMode = headerMode else {
			headerImageView.isHidden = true
			headerAnimationView.isHidden = true
			return
		}

		headerImageView.isHidden = headerMode.isAnimation
		headerAnimationView.isHidden = headerMode.isImage
	}
	
	private var shouldKeepHeaderHidden: Bool = false {
		didSet {
			updateHeaderModeVisibility()
		}
	}
	
	/// Hide the header image
	func hideHeader() {
		shouldKeepHeaderHidden = true
	}

	/// Show the header image
	func showHeader() {
		shouldKeepHeaderHidden = false
	}
	
	var tapMenuButtonHandler: (() -> Void)? {
		didSet {
			fakeNavigationBar.tapMenuButtonHandler = tapMenuButtonHandler
		}
	}

	var fakeNavigationTitle: String? {
		didSet {
			fakeNavigationBar.title = fakeNavigationTitle
		}
	}

	var fakeNavigationBarAlpha: CGFloat {
		get {
			fakeNavigationBar.alpha
		}
		set {
			fakeNavigationBar.alpha = newValue
		}
	}
}

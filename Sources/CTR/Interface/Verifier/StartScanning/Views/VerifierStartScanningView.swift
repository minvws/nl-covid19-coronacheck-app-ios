/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Lottie

class VerifierStartScanningView: BaseView {

	/// The display constants
	private struct ViewTraits {

		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
			static let topSpacing: CGFloat = 0
			static let bottomSpacing: CGFloat = 24
		}
		enum Content {
			static let spacing: CGFloat = 20
			static let topSpacing: CGFloat = 33
		}
		enum RiskIndicator {
			static let spacing: CGFloat = 8
		}
		enum Margin {
			static let edge: CGFloat = 20
			static let top: CGFloat = 16
		}
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

	private let scrollView: UIScrollView = {

		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stackView for the content
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = 0
		view.insets(.init(top: ViewTraits.Margin.top,
						  leading: 0,
						  bottom: ViewTraits.Margin.edge,
						  trailing: 0))
		return view
	}()

	private let contentStackView: UIStackView = {

		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = ViewTraits.Content.spacing
		stackView.axis = .vertical
		stackView.insets(.init(top: ViewTraits.Margin.edge,
							   leading: ViewTraits.Margin.edge,
							   bottom: ViewTraits.Margin.edge,
							   trailing: ViewTraits.Margin.edge))
		return stackView
	}()
	
	private let headerImageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		view.contentMode = .scaleAspectFit
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
		view.accessibilityTraits = .updatesFrequently
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
		button.titleLabel?.font = Fonts.bodyMedium
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
		view.spacing = ViewTraits.RiskIndicator.spacing
		if #available(iOS 15.0, *) {
			view.maximumContentSizeCategory = .accessibilityMedium
		}
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
		backgroundColor = C.white()
		
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
		
		stackView.addArrangedSubview(headerImageView)
		stackView.addArrangedSubview(headerAnimationView)
		stackView.addArrangedSubview(contentStackView)
		contentStackView.addArrangedSubview(titleLabel)
		contentStackView.addArrangedSubview(contentTextView)
		contentStackView.addArrangedSubview(showInstructionsButton)

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
			fakeNavigationBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			fakeNavigationBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

			// Scrollview
			scrollView.topAnchor.constraint(equalTo: fakeNavigationBar.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: footerButtonView.topAnchor),

			// Outer StackView
			stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			stackView.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor),
			stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
		])
		
		// Setup content views:

		NSLayoutConstraint.activate([

			// Footer view
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),

			// ClockDeviationWarningView
			clockDeviationWarningView.topAnchor.constraint(equalTo: fakeNavigationBar.bottomAnchor),
			clockDeviationWarningView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: ViewTraits.Margin.edge),
			clockDeviationWarningView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -ViewTraits.Margin.edge),
			
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
	var headerTitle: String? {
		didSet {
			titleLabel.attributedText = headerTitle?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
			let hasTitle = headerTitle?.isEmpty == false
			let spacing = hasTitle ? ViewTraits.Title.bottomSpacing : 0
			contentStackView.setCustomSpacing(spacing, after: titleLabel)
			let topMargin = hasTitle ? ViewTraits.Title.topSpacing : ViewTraits.Content.topSpacing
			contentStackView.directionalLayoutMargins.top = topMargin
			
			if headerTitle != nil, oldValue == nil {
				UIAccessibility.post(notification: .layoutChanged, argument: titleLabel)
			} else if oldValue != nil, headerTitle == nil {
				UIAccessibility.post(notification: .layoutChanged, argument: riskIndicatorLabel)
			}
		}
	}

	/// The message
	var message: String? {
		didSet {
			// Due to TextView rendering issue, check attributedText directly for old value.
			// This prevents VoiceOver unable to focus on other subviews.
			guard contentTextView.attributedText?.string != message else { return }
			contentTextView.applyHTML(message)
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
		
		NSAttributedString.makeFromHtml(
			text: params.1,
			style: .bodyDark
		) { attributedString in
			
			self.riskIndicatorLabel.attributedText = attributedString
			self.riskIndicatorStackView.setupLargeContentViewer(title: self.riskIndicatorLabel.attributedText?.string)
			self.riskIndicatorStackView.isAccessibilityElement = true
			self.riskIndicatorStackView.accessibilityLabel = self.riskIndicatorLabel.attributedText?.string
		}
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
		
		stackView.directionalLayoutMargins.top = headerMode.isImage ? ViewTraits.Margin.top : 0
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

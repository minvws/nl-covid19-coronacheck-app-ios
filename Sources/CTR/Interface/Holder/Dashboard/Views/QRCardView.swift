/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class QRCardView: BaseView {

	// MARK: - Private types

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 10
		static let shadowOpacity: Float = 0.15
		static let shadowOpacityBottomSquashedView: Float = 0.1
		static let imageDimension: CGFloat = 40
		static let titleLineHeight: CGFloat = 28
		
		// Margins
		static let imageMargin: CGFloat = 32
		static let titleLeadingAnchorDCCMargin: CGFloat = 20
		static let titleLeadingAnchorCTBMargin: CGFloat = 24
		static let titleTopAnchorDCCMargin: CGFloat = 32
		static let titleTopAnchorCTBMargin: CGFloat = 24
		static let titleTrailingToLargeIconMargin: CGFloat = 16
		static let titleTrailingToDisclosurePolicyIndicatorMargin: CGFloat = 8
		
		// Spacing
		static let topVerticalLabelSpacing: CGFloat = 18
		static let interSquashedCardSpacing: CGFloat = 10
		static let squashedCardHeight: CGFloat = 40
	}

	// MARK: - Private properties

	private let stackSize: Int

	private let squashedCards: [UIView]

	// Contains the main QRCard (i.e. the top layer of the visual stack)
	private let hostView = UIView()
	
	/// A label for accessibility to announce the role of this qr card ("Toegangsbewijs")
	private let accessibilityRoleLabel: Label = {
		let label = Label(body: " ")
		label.translatesAutoresizingMaskIntoConstraints = false
		label.accessibilityLabel = L.holder_dashboard_accessibility_access()
		return label
	}()

	private let titleLabel: Label = {
        return Label(title3: nil, montserrat: true).multiline().header()
	}()

	private let disclosurePolicyIndicatorView: DisclosurePolicyIndicatorView = {
		let view = DisclosurePolicyIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.setContentCompressionResistancePriority(.required, for: .vertical)
		view.isHidden = true
		return view
	}()
	
	private let verticalLabelsStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		return stackView
	}()

	/// Shows either `viewQRButton` or "Dit bewijs wordt nu niet gebruikt in Nederland."
	private let viewQRButtonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		return stackView
	}()
	
	private let viewQRButton: Button = {

		let button = Button(title: "", style: .roundedBlue)
		button.contentEdgeInsets = .topBottom(10) + .leftRight(32)
		return button
	}()

	// Exerts horizontal compression on viewQRButton in its stackView so that the button isn't full-width.
	private let viewQRButtonCompressingSpacer = UIView()
	
	private let thisCertificateIsNotUsedOverlayView = ThisCertificateIsNotUsedOverlayView()

	private lazy var loadingButtonOverlay: ButtonLoadingOverlayView = {
		let overlay = ButtonLoadingOverlayView()
		
		overlay.translatesAutoresizingMaskIntoConstraints = false
		overlay.isHidden = true
		return overlay
	}()

	private let largeIconImageView: UIImageView = {

		let view = UIImageView(image: I.dashboard.domestic())
		view.translatesAutoresizingMaskIntoConstraints = false
		view.setContentCompressionResistancePriority(.required, for: .horizontal)
		return view
	}()
	
	private var titleTrailingToLargeIconImageViewConstraint: NSLayoutConstraint?
	private var titleTrailingToDisclosurePolicyIndicatorViewConstraint: NSLayoutConstraint?
	private var titleLeadingAnchor: NSLayoutConstraint?
	private var titleTopAnchor: NSLayoutConstraint?

	private var reloadTimer: Timer?

	// MARK: - init

	init(stackSize: Int) {
		self.stackSize = stackSize
		squashedCards = (0 ..< stackSize - 1).map { _ in UIView() }

		super.init(frame: .zero)

		reloadTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
			self?.reapplyLabels()
			self?.reapplyButtonEnabledState()
		})
		reloadTimer?.fire()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle

	/// Setup all the views
	override func setupViews() {

		super.setupViews()

		squashedCards.forEach { squashedCardView in
			squashedCardView.translatesAutoresizingMaskIntoConstraints = false
			squashedCardView.clipsToBounds = false
			squashedCardView.backgroundColor = .white
		}

		hostView.backgroundColor = .white
		hostView.translatesAutoresizingMaskIntoConstraints = false
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		
		addSubview(accessibilityRoleLabel)

		squashedCards.reversed().forEach { squashedCardView in
			addSubview(squashedCardView)
			squashedCardView.layer.cornerRadius = ViewTraits.cornerRadius
			createShadow(view: squashedCardView, forSquashedViewIndex: squashedCards.firstIndex(of: squashedCardView)!, forTotalSquashedViewCount: squashedCards.count)
		}

		addSubview(hostView)
		hostView.layer.cornerRadius = ViewTraits.cornerRadius
		createShadow(view: hostView, hasSquashedViews: !squashedCards.isEmpty)

		hostView.addSubview(titleLabel)
		hostView.addSubview(largeIconImageView)
		hostView.addSubview(disclosurePolicyIndicatorView)
		hostView.addSubview(verticalLabelsStackView)
		hostView.addSubview(viewQRButtonStackView)
		
		viewQRButtonStackView.addArrangedSubview(viewQRButton)
		viewQRButtonStackView.addArrangedSubview(viewQRButtonCompressingSpacer)
		
		viewQRButton.addSubview(loadingButtonOverlay)

		// This has a edge-case bug if you set it in the `let viewQRButton: Button = {}` declaration, so setting it here instead.
		// (was only applicable when Settings->Accessibility->Keyboard->Full Keyboard Access was enabled)
		viewQRButton.addTarget(self, action: #selector(viewQRButtonTapped), for: .touchUpInside)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		// Setup Stack constraints:

		NSLayoutConstraint.activate([
			hostView.leadingAnchor.constraint(equalTo: leadingAnchor),
			hostView.trailingAnchor.constraint(equalTo: trailingAnchor),
			hostView.topAnchor.constraint(equalTo: topAnchor)
		])

		// Setup the squashed cards (the QR Cards that are apparently layered beneath this one):

		if squashedCards.isEmpty {

			NSLayoutConstraint.activate([
				hostView.bottomAnchor.constraint(equalTo: bottomAnchor)
			])
		} else {

			var nextTopAnchor: NSLayoutYAxisAnchor? = hostView.topAnchor
			var nextBottomAnchor: NSLayoutYAxisAnchor?

			squashedCards.forEach { squashedCardView in
				if let nextTopAnchor = nextTopAnchor {
					NSLayoutConstraint.activate([
						nextTopAnchor.constraint(equalTo: squashedCardView.topAnchor, constant: -1 * ViewTraits.interSquashedCardSpacing)
					])
				}
				NSLayoutConstraint.activate([
					squashedCardView.leadingAnchor.constraint(equalTo: leadingAnchor),
					squashedCardView.trailingAnchor.constraint(equalTo: trailingAnchor),
					squashedCardView.heightAnchor.constraint(equalTo: hostView.heightAnchor)
				])
				nextTopAnchor = squashedCardView.topAnchor
				nextBottomAnchor = squashedCardView.bottomAnchor
			}

			if let nextBottomAnchor = nextBottomAnchor {
				NSLayoutConstraint.activate([
					nextBottomAnchor.constraint(equalTo: bottomAnchor)
				])
			}
		}

		// Setup HostingView constraints:

		largeIconImageView.setContentHuggingPriority(.required, for: .vertical)

		NSLayoutConstraint.activate([
			accessibilityRoleLabel.topAnchor.constraint(equalTo: topAnchor),
			accessibilityRoleLabel.heightAnchor.constraint(equalToConstant: 1),
			
			largeIconImageView.topAnchor.constraint(equalTo: hostView.topAnchor, constant: ViewTraits.imageMargin),
			largeIconImageView.trailingAnchor.constraint(equalTo: hostView.trailingAnchor, constant: -ViewTraits.imageMargin),
			largeIconImageView.bottomAnchor.constraint(lessThanOrEqualTo: hostView.bottomAnchor),
			largeIconImageView.widthAnchor.constraint(equalToConstant: ViewTraits.imageDimension),
			largeIconImageView.heightAnchor.constraint(equalToConstant: ViewTraits.imageDimension),

			disclosurePolicyIndicatorView.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
			disclosurePolicyIndicatorView.topAnchor.constraint(equalTo: hostView.topAnchor, constant: 24),
			
			verticalLabelsStackView.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: ViewTraits.topVerticalLabelSpacing),
			verticalLabelsStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			verticalLabelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

			viewQRButtonStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			viewQRButtonStackView.trailingAnchor.constraint(equalTo: hostView.trailingAnchor, constant: -24),
			viewQRButtonStackView.topAnchor.constraint(equalTo: verticalLabelsStackView.bottomAnchor, constant: 30),
			viewQRButtonStackView.bottomAnchor.constraint(equalTo: hostView.bottomAnchor, constant: -24),

			loadingButtonOverlay.leadingAnchor.constraint(equalTo: viewQRButton.leadingAnchor),
			loadingButtonOverlay.trailingAnchor.constraint(equalTo: viewQRButton.trailingAnchor),
			loadingButtonOverlay.topAnchor.constraint(equalTo: viewQRButton.topAnchor),
			loadingButtonOverlay.bottomAnchor.constraint(equalTo: viewQRButton.bottomAnchor),

			// Break constraint when title label increases in size
			{
				let constraint = verticalLabelsStackView.topAnchor.constraint(equalTo: largeIconImageView.bottomAnchor, constant: ViewTraits.topVerticalLabelSpacing)
				constraint.priority = .defaultLow
				return constraint
			}()
		])
		
		titleTrailingToLargeIconImageViewConstraint = titleLabel.trailingAnchor.constraint(
			lessThanOrEqualTo: largeIconImageView.leadingAnchor,
			constant: -ViewTraits.titleTrailingToLargeIconMargin
		)
		titleTrailingToLargeIconImageViewConstraint?.isActive = true
		
		titleTrailingToDisclosurePolicyIndicatorViewConstraint = titleLabel.trailingAnchor.constraint(
			lessThanOrEqualTo: disclosurePolicyIndicatorView.leadingAnchor,
			constant: -ViewTraits.titleTrailingToDisclosurePolicyIndicatorMargin
		)
		titleTrailingToDisclosurePolicyIndicatorViewConstraint?.isActive = false
		
		titleLeadingAnchor = titleLabel.leadingAnchor.constraint(equalTo: hostView.leadingAnchor, constant: ViewTraits.titleLeadingAnchorDCCMargin)
		titleLeadingAnchor?.isActive = true
		
		titleTopAnchor = titleLabel.topAnchor.constraint(equalTo: hostView.topAnchor, constant: ViewTraits.titleTopAnchorDCCMargin)
		titleTopAnchor?.isActive = true
	}
	
	// MARK: - Private funcs

	var originDesiresToShowAutomaticallyBecomesValidFooter = false

	private func reapplyLabels(now: Date = Date()) {

		// Remove previous labels
		verticalLabelsStackView.removeArrangedSubviews()
 
		guard let validityTexts = validityTexts?(now) else { return }

		// Each "Row" corresponds to an origin.
		// Each Row contains an *array* of texts (simply to force newlines when needed)
		// and they are rendered as grouped together.

		validityTexts.enumerated().forEach { index, validityText in
			guard validityText.kind != .past else { return }

			validityText.lines.forEach { text in
				let label = Label(body: text)
				label.numberOfLines = 0
				verticalLabelsStackView.addArrangedSubview(label)
			}

			if case .future(let desiresToShowAutomaticallyBecomesValidFooter) = validityText.kind,
			   desiresToShowAutomaticallyBecomesValidFooter {
				self.originDesiresToShowAutomaticallyBecomesValidFooter = self.originDesiresToShowAutomaticallyBecomesValidFooter
					|| desiresToShowAutomaticallyBecomesValidFooter
			}
			
			if let buttonEnabledEvaluator = buttonEnabledEvaluator {
				let enabledState = buttonEnabledEvaluator(Date())
				if !enabledState && originDesiresToShowAutomaticallyBecomesValidFooter {
					let becomesValidLabel = Label(bodyBold: L.holderDashboardQrValidityDateAutomaticallyBecomesValidOn())
					becomesValidLabel.numberOfLines = 0

					verticalLabelsStackView.addArrangedSubview(becomesValidLabel)
					verticalLabelsStackView.setCustomSpacing(22, after: becomesValidLabel)
				}
			}
			
			// Add some padding after the last label (if it's not the last one)
			let isLastIndex = (validityTexts.count - 1) == index
			if let lastLabel = verticalLabelsStackView.arrangedSubviews.last as? Label {
				verticalLabelsStackView.setCustomSpacing(isLastIndex ? 2 : 22, after: lastLabel)
			}
		}

		if let expiryEvaluator = expiryEvaluator {
			let expiryLabel = Label(bodyBold: expiryEvaluator(Date()))
			expiryLabel.numberOfLines = 0

			if let text = expiryEvaluator(Date()) {
				expiryLabel.isHidden = false
				expiryLabel.text = text
			} else {
				expiryLabel.isHidden = true
			}

			verticalLabelsStackView.addArrangedSubview(expiryLabel)
		}
        
        // Group accessibility labels together for two reasons:
        // 1. Fix focus order issues caused by frequently removing and adding subviews
        // 2. Clearer for users to hear all information at once
        let groupedAccessibilityLabel = verticalLabelsStackView.arrangedSubviews.compactMap { arrangedView in
            arrangedView.accessibilityLabel
        }.joined(separator: " ")
        verticalLabelsStackView.isAccessibilityElement = true
        verticalLabelsStackView.shouldGroupAccessibilityChildren = true
        verticalLabelsStackView.accessibilityLabel = groupedAccessibilityLabel
        
		verticalLabelsStackView.setNeedsLayout()
	}

	private func reapplyButtonEnabledState() {
		if let buttonEnabledEvaluator = buttonEnabledEvaluator {
			let enabledState = buttonEnabledEvaluator(Date())
			viewQRButton.isEnabled = enabledState
			if shouldStyleForEU && enabledState {
				applyEUStyle()
			}
			loadingButtonOverlay.buttonAppearsEnabled = enabledState
		}
	}

	/// Create the shadow around a view
	private func createShadow(view: UIView, hasSquashedViews: Bool) {
		// Shadow
		view.layer.shadowColor = UIColor.black.cgColor

		// If there is a stack of squashed views, then halve the shadow opacity on the main `hostView`:
		view.layer.shadowOpacity = hasSquashedViews ? ViewTraits.shadowOpacity / 2 : ViewTraits.shadowOpacity
		view.layer.shadowOffset = .zero
		view.layer.shadowRadius = ViewTraits.shadowRadius

		// Cache Shadow
		view.layer.shouldRasterize = true
		view.layer.rasterizationScale = UIScreen.main.scale
	}

	private func createShadow(view: UIView, forSquashedViewIndex squashedViewIndex: Int, forTotalSquashedViewCount totalSquashedViewCount: Int) {
		// Shadow
		view.layer.shadowColor = UIColor.black.cgColor

		// Fade the shadow in (in 0.05 increments) across the stacked views (they don't all need the same shadow opacity).
		let index = (squashedViewIndex - totalSquashedViewCount) * -1
		let opacity: Float = 0.05 * Float(index)
		view.layer.shadowOpacity = opacity

		view.layer.shadowOffset = .zero
		view.layer.shadowRadius = ViewTraits.shadowRadius

		// Cache Shadow
		view.layer.shouldRasterize = true
		view.layer.rasterizationScale = UIScreen.main.scale
	}

	private func applyEUStyle() {
		largeIconImageView.image = I.dashboard.international()
	}

	// MARK: - Callbacks

	@objc func viewQRButtonTapped() {

		viewQRButtonCommand?()
	}

	// MARK: Public Access

	var validityTexts: ((Date) -> [HolderDashboardViewController.ValidityText])? {
		didSet {
			reapplyLabels()
		}
	}

	var expiryEvaluator: ((Date) -> String?)? {
		didSet {
			guard expiryEvaluator != nil else { return }
			reapplyLabels()
		}
	}

	var buttonEnabledEvaluator: ((Date) -> Bool)? {
		didSet {
			guard buttonEnabledEvaluator != nil else { return }
			reapplyButtonEnabledState()
		}
	}

	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	var viewQRButtonTitle: String? {
		didSet {
			viewQRButton.titleLabel?.font = Theme.fonts.bodySemiBold
			viewQRButton.setTitle(viewQRButtonTitle, for: .normal)
		}
	}

	var isLoading: Bool = false {
		didSet {
			loadingButtonOverlay.isHidden = !isLoading
		}
	}

	var viewQRButtonCommand: (() -> Void)?

	/// currently ignores `false`
	var shouldStyleForEU: Bool = false {
		didSet {
			guard shouldStyleForEU else { return }
			applyEUStyle()
		}
	}
	
	var isDisabledByDisclosurePolicy: Bool = false {
		didSet {
			
			if isDisabledByDisclosurePolicy {
				viewQRButtonStackView.removeArrangedSubview(viewQRButton)
				viewQRButtonStackView.removeArrangedSubview(viewQRButtonCompressingSpacer)
				viewQRButtonStackView.addArrangedSubview(thisCertificateIsNotUsedOverlayView)
				viewQRButton.isAccessibilityElement = false
			} else {
				viewQRButtonStackView.removeArrangedSubview(thisCertificateIsNotUsedOverlayView)
				viewQRButtonStackView.addArrangedSubview(viewQRButton)
				viewQRButtonStackView.addArrangedSubview(viewQRButtonCompressingSpacer)
			}
		}
	}
	
	// nil, 1G or 3G
	var disclosurePolicyLabel: String? {
		didSet {
			if let disclosurePolicyLabel = disclosurePolicyLabel {
				largeIconImageView.isHidden = true
				disclosurePolicyIndicatorView.isHidden = false
				disclosurePolicyIndicatorView.title = disclosurePolicyLabel
				titleTrailingToDisclosurePolicyIndicatorViewConstraint?.isActive = true
				titleTrailingToLargeIconImageViewConstraint?.isActive = false
				titleLeadingAnchor?.constant = ViewTraits.titleLeadingAnchorCTBMargin
				titleTopAnchor?.constant = ViewTraits.titleTopAnchorCTBMargin
			} else {
				largeIconImageView.isHidden = false
				disclosurePolicyIndicatorView.isHidden = true
				titleTrailingToDisclosurePolicyIndicatorViewConstraint?.isActive = false
				titleTrailingToLargeIconImageViewConstraint?.isActive = true
				titleLeadingAnchor?.constant = ViewTraits.titleLeadingAnchorDCCMargin
				titleTopAnchor?.constant = ViewTraits.titleTopAnchorDCCMargin
			}
			setNeedsLayout()
		}
	}
}

private final class ThisCertificateIsNotUsedOverlayView: BaseView {
	
	private struct ViewTraits {
		static let margin: CGFloat = 16
		static let cornerRadius: CGFloat = 8
	}
	
	private let label: Label = {
		let label = Label(body: L.holder_dashboard_domesticQRCard_3G_inactive_label())
		label.textColor = C.darkColor()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		return label
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.primaryBlue5()
		layer.cornerRadius = ViewTraits.cornerRadius
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		addSubview(label)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.margin),
			label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin),
			label.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin),
			label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)
		])
	}
}

private final class DisclosurePolicyIndicatorView: BaseView {
	
	private struct ViewTraits {
		static let smallMargin: CGFloat = 16
		static let largeMargin: CGFloat = 20
		static let cornerRadius: CGFloat = 8
		static let imageDimension: CGFloat = 24
	}
	
	private let iconImageView: UIImageView = {
		
		let view = UIImageView(image: I.dashboard.domestic())
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let label: Label = {
		let label = Label(title3: "", textColor: Theme.colors.primary, montserrat: true)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.lineBreakMode = .byTruncatingTail
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(.required, for: .horizontal)
		label.adjustsFontForContentSizeCategory = true
		return label
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.primaryBlue5()
		layer.cornerRadius = ViewTraits.cornerRadius
		layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(label)
		addSubview(iconImageView)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.largeMargin),
			iconImageView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
			iconImageView.heightAnchor.constraint(equalToConstant: ViewTraits.imageDimension),
			iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
			
			iconImageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -ViewTraits.smallMargin),
			
			label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.largeMargin),
			label.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.smallMargin),
			label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.smallMargin)
		])
	}
	
	var title: String? {
		didSet {
			label.text = title
		}
	}
}

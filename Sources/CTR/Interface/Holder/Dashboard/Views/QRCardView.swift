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
		static let shadowRadius: CGFloat = 24
		static let shadowOpacity: Float = 0.15
		static let imageDimension: CGFloat = 40
		
		// Margins
		static let imageMargin: CGFloat = 32
		
		// Spacing
		static let topVerticalLabelSpacing: CGFloat = 18
	}

	// MARK: - Private properties

	private let titleLabel: Label = {
		return Label(title3: nil, montserrat: true).multiline()
	}()

	private let verticalLabelsStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		return stackView
	}()

	private let viewQRButton: Button = {

		let button = Button(title: "", style: .roundedBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentEdgeInsets = .topBottom(10) + .leftRight(32)
		return button
	}()

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

	private var reloadTimer: Timer?

	// MARK: - init

	init() {
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
		view?.backgroundColor = .white
		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(titleLabel)
		addSubview(largeIconImageView)
		addSubview(verticalLabelsStackView)
		addSubview(viewQRButton)
		addSubview(loadingButtonOverlay)

		// This has a edge-case bug if you set it in the `let viewQRButton: Button = {}` declaration, so setting it here instead.
		// (was only applicable when Settings->Accessibility->Keyboard->Full Keyboard Access was enabled)
		viewQRButton.addTarget(self, action: #selector(viewQRButtonTapped), for: .touchUpInside)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		largeIconImageView.setContentHuggingPriority(.required, for: .vertical)

		NSLayoutConstraint.activate([
			largeIconImageView.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.imageMargin),
			largeIconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.imageMargin),
			largeIconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
			largeIconImageView.widthAnchor.constraint(equalToConstant: ViewTraits.imageDimension),
			largeIconImageView.heightAnchor.constraint(equalToConstant: ViewTraits.imageDimension),

			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 36),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: largeIconImageView.leadingAnchor, constant: -16),

			verticalLabelsStackView.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: ViewTraits.topVerticalLabelSpacing),
			verticalLabelsStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			verticalLabelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

			viewQRButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			viewQRButton.trailingAnchor.constraint(lessThanOrEqualTo: largeIconImageView.trailingAnchor),
			viewQRButton.topAnchor.constraint(equalTo: verticalLabelsStackView.bottomAnchor, constant: 30),
			viewQRButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),

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
	}

	// MARK: - Private funcs

	var originDesiresToShowAutomaticallyBecomesValidFooter = false

	private func reapplyLabels(now: Date = Date()) {

		// Remove previous labels
		verticalLabelsStackView.arrangedSubviews.forEach { arrangedView in
			verticalLabelsStackView.removeArrangedSubview(arrangedView)
			arrangedView.removeFromSuperview()
		}
 
		guard let validityTexts = validityTexts?(now) else { return }

		// Each "Row" corresponds to an origin.
		// Each Row contains an *array* of texts (simply to force newlines when needed)
		// and they are rendered as grouped together.

		validityTexts.forEach { validityText in

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

			// Add some padding after the last label
			if let lastLabel = verticalLabelsStackView.arrangedSubviews.last as? Label {
				verticalLabelsStackView.setCustomSpacing(22, after: lastLabel)
			}
		}

		if let expiryEvaluator = expiryEvaluator {
			let expiryLabel = Label(bodyBold: expiryEvaluator(Date()))
			expiryLabel.numberOfLines = 0
			verticalLabelsStackView.addArrangedSubview(expiryLabel)

			if let text = expiryEvaluator(Date()) {
				expiryLabel.isHidden = false
				expiryLabel.text = text
			} else {
				expiryLabel.isHidden = true
			}
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

	/// Create the shadow around the view
	private func createShadow() {

		// Shadow
		layer.shadowColor = Theme.colors.shadow.cgColor
		layer.shadowOpacity = ViewTraits.shadowOpacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.shadowRadius
		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
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
			titleLabel.text = title
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

}

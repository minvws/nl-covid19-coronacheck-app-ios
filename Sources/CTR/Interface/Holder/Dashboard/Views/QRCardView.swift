/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class QRCardView: BaseView {

	// MARK: - Public types
	struct OriginRow {
		let type: String?
		let validityString: (Date) -> HolderDashboardViewController.ValidityText
	}

	// MARK: - Private types

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 24
		static let shadowOpacity: Float = 0.15
		
		// Spacing
		static let topVerticalLabelSpacing: CGFloat = 16
	}

	// MARK: - Private properties

	private let regionLabel: Label = {
		let label = Label(title3: nil).multiline().header()
		label.textColor = Theme.colors.primary
		return label
	}()

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

		let button = Button(title: "", style: .primary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.rounded = true
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

		let view = UIImageView(image: .domesticQRIcon)
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

		addSubview(regionLabel)
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
			regionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 28),
			regionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			regionLabel.trailingAnchor.constraint(lessThanOrEqualTo: largeIconImageView.leadingAnchor, constant: -16),

			largeIconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
			largeIconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
			largeIconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),

			titleLabel.leadingAnchor.constraint(equalTo: regionLabel.leadingAnchor),
			titleLabel.topAnchor.constraint(equalTo: regionLabel.bottomAnchor, constant: 8),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: largeIconImageView.leadingAnchor, constant: -16),

			verticalLabelsStackView.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: ViewTraits.topVerticalLabelSpacing),
			verticalLabelsStackView.leadingAnchor.constraint(equalTo: regionLabel.leadingAnchor),
			verticalLabelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

			viewQRButton.leadingAnchor.constraint(equalTo: regionLabel.leadingAnchor),
			viewQRButton.trailingAnchor.constraint(lessThanOrEqualTo: largeIconImageView.trailingAnchor),
			viewQRButton.topAnchor.constraint(equalTo: verticalLabelsStackView.bottomAnchor, constant: 38),
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

	private func reapplyLabels() {

		// Remove previous labels
		verticalLabelsStackView.arrangedSubviews.forEach { arrangedView in
			verticalLabelsStackView.removeArrangedSubview(arrangedView)
			arrangedView.removeFromSuperview()
		}

		originRows?.forEach { row in
			let validityText = row.validityString(Date())
			guard validityText.kind != .past else { return }

			if let type = row.type {
				let qrTypeLabel = Label(body: type + (validityText.texts.isEmpty ? "" : ":"))
				qrTypeLabel.numberOfLines = 0
				verticalLabelsStackView.addArrangedSubview(qrTypeLabel)
			}

			validityText.texts.forEach { text in
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
		regionLabel.textColor = Theme.colors.europa
		viewQRButton.backgroundColor = Theme.colors.europa
		viewQRButton.setTitleColor(Theme.colors.greenGrey, for: .normal)
		largeIconImageView.image = .euQRIcon
	}

	// MARK: - Callbacks

	@objc func viewQRButtonTapped() {

		viewQRButtonCommand?()
	}

	// MARK: Public Access

	var originRows: [OriginRow]? {
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

	var region: String? {
		didSet {
			regionLabel.text = region
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

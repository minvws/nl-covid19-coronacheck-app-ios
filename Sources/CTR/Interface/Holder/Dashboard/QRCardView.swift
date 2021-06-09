//
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
		let type: String
		let validityStringEvaluator: (Date) -> HolderDashboardViewController.ValidityText
	}

	// MARK: - Private types

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 24
		static let shadowOpacity: Float = 0.15
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
		button.addTarget(self, action: #selector(viewQRButtonTapped), for: .touchUpInside)
		return button
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
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

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

			verticalLabelsStackView.topAnchor.constraint(equalTo: largeIconImageView.bottomAnchor, constant: 16),
			verticalLabelsStackView.leadingAnchor.constraint(equalTo: regionLabel.leadingAnchor),
			verticalLabelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

			viewQRButton.leadingAnchor.constraint(equalTo: regionLabel.leadingAnchor),
			viewQRButton.trailingAnchor.constraint(equalTo: largeIconImageView.trailingAnchor),
			viewQRButton.topAnchor.constraint(equalTo: verticalLabelsStackView.bottomAnchor, constant: 38),
			viewQRButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
		])
	}

	// MARK: - Private funcs

	private func reapplyLabels() {

		// Remove previous labels
		verticalLabelsStackView.arrangedSubviews.forEach { arrangedView in
			verticalLabelsStackView.removeArrangedSubview(arrangedView)
			arrangedView.removeFromSuperview()
		}

		originRows?.forEach { row in
			let validityText = row.validityStringEvaluator(Date())
			guard validityText.kind != .past else { return }

			let qrTypeLabel = Label(body: row.type + (validityText.text.isEmpty ? "" : ":"))
			qrTypeLabel.numberOfLines = 0
			verticalLabelsStackView.addArrangedSubview(qrTypeLabel)

			let validUntilLabel = Label(body: validityText.text)
			validUntilLabel.numberOfLines = 0

			if case .future = validityText.kind {
				validUntilLabel.textColor = Theme.colors.iosBlue
			}

			verticalLabelsStackView.addArrangedSubview(validUntilLabel)

			verticalLabelsStackView.setCustomSpacing(22, after: validUntilLabel)
		}

		if let expiryEvaluator = expiryEvaluator {
			let validityLabel = Label(bodyBold: expiryEvaluator(Date()))
			validityLabel.numberOfLines = 0
			verticalLabelsStackView.addArrangedSubview(validityLabel)

			if let text = expiryEvaluator(Date()) {
				validityLabel.isHidden = false
				validityLabel.text = text
			} else {
				validityLabel.isHidden = true
			}
		}

		verticalLabelsStackView.setNeedsLayout()
	}

	private func reapplyButtonEnabledState() {
		if let buttonEnabledEvaluator = buttonEnabledEvaluator {
			viewQRButton.isEnabled = buttonEnabledEvaluator(Date())

			if shouldStyleForEU {
				applyEUStyle()
			}
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
		viewQRButton.setTitleColor(Theme.colors.grey4, for: .normal)
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

	var viewQRButtonCommand: (() -> Void)?

	/// currently ignores `false`
	var shouldStyleForEU: Bool = false {
		didSet {
			guard shouldStyleForEU else { return }
			applyEUStyle()
		}
	}

}

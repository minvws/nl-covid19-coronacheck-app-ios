/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ShowQRScreenshotBlockingView: BaseView {

	// MARK: - Private types

	/// The display constants
	private enum ViewTraits: CGFloat {

		// Dimensions
		case cornerRadius = 15
		case headerImageWidth = 73
		case labelHorizontalPadding = 24
		case titleLabelBottomPadding = 8
	}

	// MARK: - Private properties

	private let titleLabel: UILabel = {
		let label = Label(nil, font: Theme.fonts.headlineBoldMontserrat, textColor: Theme.colors.dark)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.numberOfLines = 2
		label.adjustsFontSizeToFitWidth = true
		label.text = L.holderShowqrScreenshotwarningTitle()
		label.setContentHuggingPriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        label.header()

		return label
	}()

	private let subtitleLabel: UILabel = {
		let label = Label(nil, font: Theme.fonts.body, textColor: Theme.colors.dark)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.numberOfLines = 2
		label.adjustsFontSizeToFitWidth = true
		label.text = L.holderShowqrScreenshotwarningSubtitle()
		label.setContentHuggingPriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)

		return label
	}()

	private let countdownLabel: UILabel = {
		let label = Label(nil, font: Theme.fonts.subhead, textColor: Theme.colors.grey2)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.numberOfLines = 1
		label.adjustsFontSizeToFitWidth = true
		label.text = L.holderShowqrScreenshotwarningMessage("-")
		label.setContentHuggingPriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
		label.accessibilityTraits = .updatesFrequently
		label.accessibilityLabel = L.holderShowqrScreenshotwarningCountdownAccessibilityLabel()
		return label
	}()

	private let headerImageView: UIImageView = {
		let imageView = UIImageView(image: I.dashboard.redScreenSmall())
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .center
		imageView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
		return imageView
	}()

	// MARK: - init

	init() {
		super.init(frame: .zero)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifecycle

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		clipsToBounds = true
		layer.cornerRadius = ViewTraits.cornerRadius.rawValue
		layer.borderWidth = 1
		layer.borderColor = Theme.colors.grey3.cgColor
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(headerImageView)
		addSubview(titleLabel)
		addSubview(subtitleLabel)
		addSubview(countdownLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			headerImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			headerImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
			headerImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
			headerImageView.widthAnchor.constraint(equalToConstant: ViewTraits.headerImageWidth.rawValue),

			titleLabel.centerYAnchor.constraint(lessThanOrEqualTo: centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.labelHorizontalPadding.rawValue),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.labelHorizontalPadding.rawValue),

			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ViewTraits.titleLabelBottomPadding.rawValue),
			subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: ViewTraits.labelHorizontalPadding.rawValue),
			subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -ViewTraits.labelHorizontalPadding.rawValue),
			subtitleLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor),

			countdownLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor),
			countdownLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: ViewTraits.labelHorizontalPadding.rawValue),
			countdownLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -ViewTraits.labelHorizontalPadding.rawValue),
			countdownLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	// MARK: - External setters

	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	var subtitle: String? {
		didSet {
			subtitleLabel.text = subtitle
		}
	}

	func setCountdown(text: String?, voiceoverText: String?) {
		countdownLabel.accessibilityValue = voiceoverText
		countdownLabel.text = text
	}
}

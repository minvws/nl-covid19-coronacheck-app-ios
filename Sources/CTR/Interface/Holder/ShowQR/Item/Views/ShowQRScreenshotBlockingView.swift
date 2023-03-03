/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Resources

class ShowQRScreenshotBlockingView: BaseView {

	// MARK: - Private types

	/// The display constants
	private enum ViewTraits: CGFloat {

		// Dimensions
		case cornerRadius = 15
		case headerImageWidth = 73
		case labelHorizontalPadding = 24
		case titleLabelBottomPadding = 8
		
		enum Title {
			static let lineHeight: CGFloat = 22
		}
		enum Subtitle {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Countdown {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}
	}

	// MARK: - Private properties

	private let titleLabel: Label = {
		let label = Label(nil, font: Fonts.headlineBoldMontserrat)
		label.numberOfLines = 2
		label.adjustsFontSizeToFitWidth = true
		label.attributedText = L.holderShowqrScreenshotwarningTitle().setLineHeight(ViewTraits.Title.lineHeight,
																					alignment: .center)
		label.setContentHuggingPriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
		label.header()

		return label
	}()

	private let subtitleLabel: Label = {
		let label = Label(nil, font: Fonts.body)
		label.numberOfLines = 2
		label.adjustsFontSizeToFitWidth = true
		label.attributedText = L.holderShowqrScreenshotwarningSubtitle().setLineHeight(ViewTraits.Subtitle.lineHeight,
																					   alignment: .center,
																					   kerning: ViewTraits.Subtitle.kerning)
		label.setContentHuggingPriority(.required, for: .vertical)
		label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)

		return label
	}()

	private let countdownLabel: Label = {
		let label = Label(nil, font: Fonts.subhead)
		label.numberOfLines = 1
		label.adjustsFontSizeToFitWidth = true
		label.attributedText = L.holderShowqrScreenshotwarningMessage("-").setLineHeight(ViewTraits.Countdown.lineHeight,
																						 alignment: .center,
																						 kerning: ViewTraits.Countdown.kerning,
																						 textColor: C.secondaryText()!)
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
		layer.borderColor = C.grey3()?.cgColor
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

	/// Only used for testing
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				alignment: .center
			)
		}
	}
	
	/// Only used for testing
	var subtitle: String? {
		didSet {
			subtitleLabel.attributedText = subtitle?.setLineHeight(
				ViewTraits.Subtitle.lineHeight,
				alignment: .center,
				kerning: ViewTraits.Subtitle.kerning
			)
		}
	}
	
	func setCountdown(text: String?, voiceoverText: String?) {
		countdownLabel.accessibilityValue = voiceoverText
		countdownLabel.attributedText = text?.setLineHeight(
			ViewTraits.Countdown.lineHeight,
			alignment: .center,
			kerning: ViewTraits.Countdown.kerning,
			textColor: C.secondaryText()!
		)
	}
}

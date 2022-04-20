/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

class VerifierClockDeviationWarningView: BaseView {

	// MARK: - Private types

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 10
		static let shadowOpacity: Float = 0.15
		static let shadowOpacityBottomSquashedView: Float = 0.1
		static let imageDimension: CGFloat = 40
		static let messageLineHeight: CGFloat = 22
		static let messageKerning: CGFloat = -0.41

		// Margins
		static let imageMargin: CGFloat = 32

		// Spacing
		static let topVerticalLabelSpacing: CGFloat = 18
		static let interSquashedCardSpacing: CGFloat = 10
		static let squashedCardHeight: CGFloat = 40
	}

	// MARK: - Private properties

	private let iconImageView: UIImageView = {
		let imageView = UIImageView(image: I.clockwarning_icon())
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	private let messageLabel: Label = {
		return Label(body: "", textColor: C.black()!).multiline()
	}()

	private let button: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.contentHorizontalAlignment = .leading
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	// MARK: - Lifecycle

	/// Setup all the views
	override func setupViews() {

		super.setupViews()

		backgroundColor = C.white()
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()

		addSubview(messageLabel)
		addSubview(button)
		addSubview(iconImageView)

		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
			iconImageView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -2),
			iconImageView.trailingAnchor.constraint(lessThanOrEqualTo: messageLabel.leadingAnchor, constant: 8),
			
			messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 72),
			messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
			messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),

			button.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor),
			button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
			button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
		])
	}

	// MARK: - Private funcs

	/// Create the shadow around a view
	private func createShadow() {
		// Shadow
		layer.shadowColor = C.shadow()?.cgColor

		// If there is a stack of squashed views, then halve the shadow opacity on the main `hostView`:
		layer.shadowOpacity = ViewTraits.shadowOpacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.shadowRadius

		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
	}

	// MARK: - Callbacks

	@objc func buttonTapped() {

		buttonCommand?()
	}

	// MARK: Public Access

	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight,
																 kerning: ViewTraits.messageKerning)
		}
	}
	var buttonTitle: String? {
		didSet {
			button.title = buttonTitle
		}
	}

	var buttonCommand: (() -> Void)?
}

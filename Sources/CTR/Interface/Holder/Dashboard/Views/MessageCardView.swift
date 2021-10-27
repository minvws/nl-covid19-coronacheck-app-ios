/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MessageCardView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 10
		static let shadowOpacity: Float = 0.15
		static let buttonSize: CGFloat = 20
		static let imageWidth: CGFloat = 30
		static let imageHeight: CGFloat = 32

		// Margins
		static let margin: CGFloat = 24.0
		
		// Label
		static let lineHeight: CGFloat = 22
		static let kerning: CGFloat = -0.41
	}

	/// The title label
	private let titleLabel: Label = {

        return Label(body: nil).multiline().header()
	}()

	/// The close button
	private let closeButton: TappableButton = {

		let button = TappableButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(I.smallCross(), for: .normal)
		button.contentHorizontalAlignment = .center
		button.isHidden = true
		return button
	}()

	/// The callToAction button
	private let callToActionButton: Button = {

		let button = Button(title: "CTA!", style: Button.ButtonType.textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .leading
		button.isHidden = true
		return button
	}()

	private let messageWithCloseButtonStackView: UIStackView = {

		let stackView = UIStackView()
		stackView.alignment = .top
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 8
		return stackView
	}()

	private let callToActionButtonStackView: UIStackView = {

		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .white
		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()

		closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		callToActionButton.addTarget(self, action: #selector(callToActionButtonTapped), for: .touchUpInside)
	}

	/// Create the shadow around the view
	func createShadow() {

		// Shadow
		layer.shadowColor = Theme.colors.shadow.cgColor
		layer.shadowOpacity = ViewTraits.shadowOpacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.shadowRadius
		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(messageWithCloseButtonStackView)
		addSubview(callToActionButtonStackView)

		messageWithCloseButtonStackView.addArrangedSubview(titleLabel)
		messageWithCloseButtonStackView.addArrangedSubview(closeButton)

		callToActionButtonStackView.addArrangedSubview(callToActionButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			messageWithCloseButtonStackView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
			messageWithCloseButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
			messageWithCloseButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

			messageWithCloseButtonStackView.bottomAnchor.constraint(equalTo: callToActionButtonStackView.topAnchor, constant: -10),

			callToActionButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
			callToActionButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
			callToActionButtonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),

			closeButton.widthAnchor.constraint(equalToConstant: 42)
		])
	}

	/// User tapped on the close button
	@objc func closeButtonTapped() {

		closeButtonTappedCommand?()
	}

	/// User tapped on the callToAction button
	@objc func callToActionButtonTapped() {

		callToActionButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.lineHeight,
															 kerning: ViewTraits.kerning)
		}
	}

	/// The title
	var callToActionButtonText: String? {
		didSet {
			callToActionButton.title = callToActionButtonText
		}
	}

	/// The user tapped on the close button
	var closeButtonTappedCommand: (() -> Void)? {
		didSet {
			closeButton.isHidden = closeButtonTappedCommand == nil
		}
	}

	/// The user tapped on the callToAction button
	var callToActionButtonTappedCommand: (() -> Void)? {
		didSet {
			callToActionButton.isHidden = callToActionButtonTappedCommand == nil
		}
	}
}

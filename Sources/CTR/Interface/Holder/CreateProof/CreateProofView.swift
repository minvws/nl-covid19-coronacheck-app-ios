/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class CreateProofView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22
		static let imageRatio: CGFloat = 0.75
		static let imageMargin: CGFloat = 26

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 54.0
		static let titleTopMargin: CGFloat = 34.0
		static let messageTopMargin: CGFloat = 24.0
	}

	/// The container for centering the image
	private let imageContainerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .center
		view.image = .qrAnimation
		return view
	}()

	/// The title label
	let titleLabel: Label = {

		return Label(title3: nil, montserrat: true).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// the update button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		imageContainerView.addSubview(imageView)
		addSubview(imageContainerView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(primaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Container
			imageContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			imageContainerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			imageContainerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

			// Image
			imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
			imageView.leadingAnchor.constraint(
				equalTo: imageContainerView.leadingAnchor,
				constant: ViewTraits.imageMargin
			),
			imageView.trailingAnchor.constraint(
				equalTo: imageContainerView.trailingAnchor,
				constant: -ViewTraits.imageMargin
			),
			imageView.topAnchor.constraint(
				equalTo: imageContainerView.topAnchor,
				constant: UIDevice.current.isSmallScreen ? 0 : ViewTraits.imageMargin
			),
			imageView.bottomAnchor.constraint(
				equalTo: imageContainerView.bottomAnchor,
				constant: UIDevice.current.isSmallScreen ? 0 : -ViewTraits.imageMargin
			),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: imageContainerView.bottomAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			primaryButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = .makeFromHtml(
				text: message,
				font: Theme.fonts.body,
				textColor: Theme.colors.dark
			)
		}
	}

	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}

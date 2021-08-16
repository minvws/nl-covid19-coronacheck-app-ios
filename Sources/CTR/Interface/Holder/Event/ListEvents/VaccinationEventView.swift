/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VaccinationEventView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 22
		static let titleKerning: CGFloat = -0.41
		static let messageLineHeight: CGFloat = 18
		static let messageKerning: CGFloat = -0.24
		static let messageParagraphSpacing: CGFloat = 6

		// Margins
		static let margin: CGFloat = 20.0
		static let messageTopMargin: CGFloat = 4.0
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(bodyBold: nil).multiline()
	}()

	/// The message text
	private let messageLabel: Label = {

        return Label(subhead: nil).multiline()
	}()

	/// The link label
	private let linkLabel: Label = {

		return Label(bodySemiBold: nil).multiline()
	}()

	private let detailsButton: UIButton = {

		let button = UIButton()
		button.backgroundColor = .clear
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
		messageLabel.textColor = Theme.colors.grey1
		linkLabel.textColor = Theme.colors.iosBlue
		detailsButton.addTarget(
			self,
			action: #selector(disclaimerButtonTapped),
			for: .touchUpInside
		)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		detailsButton.embed(in: self)

		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(linkLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: 24
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -8
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			messageLabel.bottomAnchor.constraint(
				equalTo: linkLabel.topAnchor,
				constant: -8
			),

			// Link
			linkLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor
			),
			linkLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			linkLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -24
			)
		])
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()

		accessibilityElements = [detailsButton]
	}

	/// User tapped on the primary button
	@objc func disclaimerButtonTapped() {

		disclaimerButtonTappedCommand?()
	}

	func setAccessibilityLabel() {

        detailsButton.accessibilityLabel = "\(titleLabel.text ?? "") \(messageLabel.text ?? "")"
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
			setAccessibilityLabel()
		}
	}

	/// The message
	var subTitle: String? {
		didSet {
			messageLabel.attributedText = .makeFromHtml(
				text: subTitle,
				font: Theme.fonts.subhead,
				textColor: Theme.colors.grey1,
				lineHeight: ViewTraits.messageLineHeight,
				kern: ViewTraits.messageKerning,
				paragraphSpacing: ViewTraits.messageParagraphSpacing
			)
			setAccessibilityLabel()
		}
	}

	var link: String? {
		didSet {
			linkLabel.attributedText = link?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning,
				textColor: Theme.colors.iosBlue
			)
		}
	}

	/// The user tapped on the disclaimer button
	var disclaimerButtonTappedCommand: (() -> Void)?
}

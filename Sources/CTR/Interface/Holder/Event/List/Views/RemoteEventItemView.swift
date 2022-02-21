/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class RemoteEventItemView: BaseView {

	/// The display constants
	private struct ViewTraits {
		enum Link {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Title {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Message {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let paragraphSpacing: CGFloat = 6
		}

		// Margins
		static let margin: CGFloat = 20.0
		static let messageTopMargin: CGFloat = 4.0
	}

	/// The title label
	private let titleLabel: Label = {

        return Label(bodyBold: nil).multiline().header()
	}()

	/// The message text
	private let messageLabel: Label = {

        return Label(subhead: nil).multiline()
	}()

	/// The link label
	private let linkLabel: Label = {

		return Label(bodyMedium: nil).multiline()
	}()

	private let backgroundButton: UIButton = {

		let button = UIButton()
		button.backgroundColor = .clear
		button.translatesAutoresizingMaskIntoConstraints = false
		
		return button
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
		messageLabel.textColor = Theme.colors.grey1
		linkLabel.textColor = Theme.colors.primary
		backgroundButton.addTarget(
			self,
			action: #selector(disclaimerButtonTapped),
			for: .touchUpInside
		)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		backgroundButton.embed(in: self)

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

		backgroundButton.isAccessibilityElement = true
		linkLabel.isAccessibilityElement = false
		
		accessibilityElements = [titleLabel, messageLabel, backgroundButton]
	}

	/// User tapped on the primary button
	@objc func disclaimerButtonTapped() {

		disclaimerButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}

	/// The message
	var subTitle: String? {
		didSet {
			messageLabel.attributedText = .style(
				text: subTitle,
				style: NSAttributedString.HTMLStyle(
					font: Theme.fonts.subhead,
					textColor: Theme.colors.grey1,
					lineHeight: ViewTraits.Message.lineHeight,
					kern: ViewTraits.Message.kerning,
					paragraphSpacing: ViewTraits.Message.paragraphSpacing
				)
			)
		}
	}

	var link: String? {
		didSet {
			linkLabel.attributedText = link?.setLineHeight(
				ViewTraits.Link.lineHeight,
				kerning: ViewTraits.Link.kerning,
				textColor: Theme.colors.primary
			)
			backgroundButton.accessibilityLabel = link
		}
	}

	/// The user tapped on the disclaimer button
	var disclaimerButtonTappedCommand: (() -> Void)?
}

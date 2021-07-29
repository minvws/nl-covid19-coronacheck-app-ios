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

	/// The disclaimer image
	private let disclaimerImageView: UIImageView = {
		let view = UIImageView(image: .questionMark)
		view.tintColor = Theme.colors.dark
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

		return Label(bodyMedium: nil).multiline()
	}()

	/// The message text
	private let messageTextView: TextView = {

		return TextView()
	}()

	private let disclaimerButton: UIButton = {

		let button = UIButton()
		button.backgroundColor = .clear
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
		disclaimerButton.addTarget(
			self,
			action: #selector(disclaimerButtonTapped),
			for: .touchUpInside
		)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		disclaimerButton.embed(in: self)

		addSubview(disclaimerImageView)
		addSubview(titleLabel)
		addSubview(messageTextView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Disclaimer View
			disclaimerImageView.trailingAnchor.constraint( equalTo: trailingAnchor),
			disclaimerImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
			disclaimerImageView.widthAnchor.constraint(equalToConstant: 21),
			disclaimerImageView.heightAnchor.constraint(equalToConstant: 21),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: 24
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: disclaimerImageView.leadingAnchor
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageTextView.topAnchor,
				constant: -8
			),

			// Message
			messageTextView.leadingAnchor.constraint(
				equalTo: leadingAnchor
			),
			messageTextView.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			messageTextView.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -24
			)
		])
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()

		accessibilityElements = [disclaimerButton]
	}

	/// User tapped on the primary button
	@objc func disclaimerButtonTapped() {

		disclaimerButtonTappedCommand?()
	}

	func setAccessibilityLabel() {

        disclaimerButton.accessibilityLabel = "\(titleLabel.text ?? "") \(messageTextView.text ?? "")"
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
			messageTextView.attributedText = .makeFromHtml(
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

	/// The user tapped on the disclaimer button
	var disclaimerButtonTappedCommand: (() -> Void)?
}

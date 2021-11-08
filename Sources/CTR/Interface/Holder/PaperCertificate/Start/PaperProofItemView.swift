/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PaperProofItemView: BaseView {

	/// The display constants
	private enum ViewTraits {

		enum Title {
			static let lineHeight: CGFloat = 20
			static let kerning: CGFloat = -0.41
		}

		enum Message {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}

		enum Icon {
			static let size: CGFloat = 20
		}

		enum Spacing {
			static let iconLeading: CGFloat = 12
			static let iconTrailing: CGFloat = 24
			static let message: CGFloat = 8
		}
	}

	private let iconView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

		return Label(bodySemiBold: nil).multiline()
	}()

	/// The message label
	private let messageLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()

		addSubview(iconView)
		addSubview(titleLabel)
		addSubview(messageLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			iconView.widthAnchor.constraint(equalToConstant: ViewTraits.Icon.size),
			iconView.heightAnchor.constraint(equalToConstant: ViewTraits.Icon.size),
			iconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
			iconView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.Spacing.iconLeading
			),

			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.leadingAnchor.constraint(
				equalTo: iconView.trailingAnchor,
				constant: ViewTraits.Spacing.iconTrailing
			),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

			messageLabel.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: ViewTraits.Spacing.message
			),
			messageLabel.leadingAnchor.constraint(
				equalTo: iconView.trailingAnchor,
				constant: ViewTraits.Spacing.iconTrailing
			),
			messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {
		super.setupAccessibility()

		titleLabel.isAccessibilityElement = false
		messageLabel.isAccessibilityElement = false

		guard let title = title, let message = message else { return }
		accessibilityLabel = title + " " + message
	}

	// MARK: Public Access

	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
			setupAccessibility()
		}
	}

	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(
				ViewTraits.Message.lineHeight,
				kerning: ViewTraits.Message.kerning,
				textColor: Theme.colors.secondaryText
			)
			setupAccessibility()
		}
	}

	var icon: UIImage? {
		didSet {
			iconView.image = icon
		}
	}
}

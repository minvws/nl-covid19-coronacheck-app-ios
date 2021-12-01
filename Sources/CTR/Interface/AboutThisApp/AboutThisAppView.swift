/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutThisAppView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		enum ListHeader {
			static let lineHeight: CGFloat = 16
			static let height: CGFloat = 38
		}

		enum Footer {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}

		enum StackView {
			static let bottomMargin: CGFloat = 32
		}
	}

	private let messageTextView: TextView = {

		return TextView()
	}()

	/// The stack view for the menu items
	let menuStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 0
		return view
	}()

	private let appVersionLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	private let configVersionLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		stackView.distribution = .fill
		appVersionLabel.textColor = Theme.colors.grey1
		configVersionLabel.textColor = Theme.colors.grey1
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(messageTextView)
		stackView.addArrangedSubview(menuStackView)
		stackView.setCustomSpacing(ViewTraits.StackView.bottomMargin, after: menuStackView)
		stackView.addArrangedSubview(appVersionLabel)
		stackView.setCustomSpacing(24, after: appVersionLabel)
		stackView.addArrangedSubview(configVersionLabel)
	}

	override func setupViewConstraints() {

		super.setupViewConstraints()
//		NSLayoutConstraint.activate([
//			topHeaderLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.ListHeader.height),
//			bottomHeaderLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.ListHeader.height)
//		])
	}

	// MARK: Public Access

	/// The message
	var message: String? {
		didSet {
			messageTextView.attributedText = .makeFromHtml(text: message, style: .bodyDark)
		}
	}

//	/// The list header
//	var topListHeader: String? {
//		didSet {
//			topHeaderLabel.attributedText = topListHeader?.setLineHeight(
//				ViewTraits.ListHeader.lineHeight
//			)
//		}
//	}

	/// The app version
	var appVersion: String? {
		didSet {
			appVersionLabel.attributedText = appVersion?.setLineHeight(
				ViewTraits.Footer.lineHeight,
				kerning: ViewTraits.Footer.kerning,
				textColor: Theme.colors.grey1
			)
		}
	}

	/// The config version
	var configVersion: String? {
		didSet {
			configVersionLabel.attributedText = configVersion?.setLineHeight(
				ViewTraits.Footer.lineHeight,
				kerning: ViewTraits.Footer.kerning,
				textColor: Theme.colors.grey1
			)
		}
	}

	func createMenuStackView(title: String) -> UIStackView {

		/// The stack view for the menu items
		let menuOptionStackView: UIStackView = {

			let view = UIStackView()
			view.translatesAutoresizingMaskIntoConstraints = false
			view.axis = .vertical
			view.alignment = .fill
			view.distribution = .fill
			view.spacing = 0
			return view
		}()

		// Title Label
		let label = Label(caption1SemiBold: nil).multiline().header()
		label.attributedText = title.setLineHeight(ViewTraits.ListHeader.lineHeight)
		menuOptionStackView.addArrangedSubview(label)

		return menuOptionStackView
	}
}

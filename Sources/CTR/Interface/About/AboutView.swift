/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let messageLineHeight: CGFloat = 22
		static let messageLineKerning: CGFloat = -0.41
		static let listHeaderLineHeight: CGFloat = 16
		static let listHeaderHeight: CGFloat = 38
		static let versionLineHeight: CGFloat = 18
		static let versionLineKerning: CGFloat = -0.24
	}

	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	private let listHeaderLabel: Label = {

        return Label(caption1SemiBold: nil).multiline().header()
	}()

	/// The stack view for the menu items
	let itemStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 0
		return view
	}()

	private let versionLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		stackView.distribution = .fill
		versionLabel.textColor = Theme.colors.grey1
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(listHeaderLabel)
		stackView.setCustomSpacing(0, after: listHeaderLabel)
		stackView.addArrangedSubview(itemStackView)
		stackView.setCustomSpacing(24, after: itemStackView)
		stackView.addArrangedSubview(versionLabel)
	}

	override func setupViewConstraints() {

		super.setupViewConstraints()
		NSLayoutConstraint.activate([
			listHeaderLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.listHeaderHeight)
		])
	}

	// MARK: Public Access

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

	/// The list header
	var listHeader: String? {
		didSet {
			listHeaderLabel.attributedText = listHeader?.setLineHeight(
				ViewTraits.listHeaderLineHeight
			)
		}
	}

	/// The version
	var version: String? {
		didSet {
			versionLabel.attributedText = version?.setLineHeight(
				ViewTraits.versionLineHeight,
				kerning: ViewTraits.versionLineKerning,
				textColor: Theme.colors.grey1
			)
		}
	}
}

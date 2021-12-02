/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanLogView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		enum ListHeader {
			static let lineHeight: CGFloat = 16
			static let height: CGFloat = 38
			static let spacing: CGFloat = 8
		}

		enum Footer {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let spacing: CGFloat = 24
		}

		enum StackView {
			static let topMargin: CGFloat = 40
			static let bottomMargin: CGFloat = 32
		}
	}

	let messageTextView: TextView = {

		return TextView()
	}()

	/// The stack view for the menu items
	let logStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 0
		return view
	}()

	private let footerLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		stackView.distribution = .fill
		footerLabel.textColor = Theme.colors.grey1
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(messageTextView)
		stackView.setCustomSpacing(ViewTraits.StackView.topMargin, after: messageTextView)
		stackView.addArrangedSubview(logStackView)
		stackView.setCustomSpacing(ViewTraits.StackView.bottomMargin, after: logStackView)
		stackView.addArrangedSubview(footerLabel)
	}

	// MARK: Public Access

	/// The message
	var message: String? {
		didSet {
			messageTextView.attributedText = .makeFromHtml(text: message, style: .bodyDark)
		}
	}

	/// The app version
	var footer: String? {
		didSet {
			footerLabel.attributedText = footer?.setLineHeight(
				ViewTraits.Footer.lineHeight,
				kerning: ViewTraits.Footer.kerning,
				textColor: Theme.colors.grey1
			)
		}
	}
}

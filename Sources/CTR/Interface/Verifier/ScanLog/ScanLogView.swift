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

		enum ListHeader {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.24
			static let topMargin: CGFloat = 40
		}

		enum Footer {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let spacing: CGFloat = 24
		}

		enum StackView {
			static let topMargin: CGFloat = 16
			static let bottomMargin: CGFloat = 24
			static let spacing: CGFloat = 24
		}

		enum Line {
			static let height: CGFloat = 1
		}

		enum Entry {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.24
		}
	}

	let messageTextView: TextView = {

		return TextView()
	}()

	private let listHeaderLabel: Label = {

		return Label(bodySemiBold: nil)
	}()

	/// The stack view for the menu items
	let logStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.StackView.spacing
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
		stackView.setCustomSpacing(ViewTraits.ListHeader.topMargin, after: messageTextView)
		stackView.addArrangedSubview(listHeaderLabel)
		stackView.setCustomSpacing(ViewTraits.StackView.topMargin, after: listHeaderLabel)
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

	var listHeader: String? {
		didSet {
			listHeaderLabel.attributedText = listHeader?.setLineHeight(
				ViewTraits.ListHeader.lineHeight,
				kerning: ViewTraits.ListHeader.kerning
			)
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

	// Helpers for log stack view

	private func createLineView() -> UIView {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.line
		return view
	}

	func addLineToLogStackView() {

		let lineView = createLineView()
		NSLayoutConstraint.activate([
			lineView.heightAnchor.constraint(equalToConstant: ViewTraits.Line.height)
		])
		logStackView.addArrangedSubview(lineView)
	}

	func createLabel(_ text: String?) -> Label {

		let label = Label(body: nil)
		label.attributedText = text?.setLineHeight(
			ViewTraits.Entry.lineHeight,
			kerning: ViewTraits.Entry.kerning,
			textColor: Theme.colors.dark
		)
		return label
	}
}

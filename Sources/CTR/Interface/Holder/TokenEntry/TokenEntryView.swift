/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenEntryView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22
		static let gradientHeight: CGFloat = 30.0

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 54.0
		static let titleTopMargin: CGFloat = 24.0
		static let messageTopMargin: CGFloat = 24.0
		static let entryMargin: CGFloat = 16.0
		static let errorMargin: CGFloat = 8.0
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()

	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The request token entry view
	let tokenEntryView: EntryView = {

		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.inputField.autocapitalizationType = .allCharacters
		if #available(iOS 12.0, *) {
			view.inputField.textContentType = .oneTimeCode
		}
		return view
	}()

	/// The verification entry view
	let verificationEntryView: EntryView = {

		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.inputField.autocapitalizationType = .allCharacters
		if #available(iOS 12.0, *) {
			view.inputField.textContentType = .oneTimeCode
		}

		return view
	}()

	let errorView: ErrorView = {

		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	/// The message label
	let textLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		stackView.distribution = .fill
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(tokenEntryView)
		stackView.setCustomSpacing(0, after: tokenEntryView)
		stackView.addArrangedSubview(verificationEntryView)
		stackView.setCustomSpacing(8, after: verificationEntryView)
		stackView.addArrangedSubview(errorView)
		stackView.setCustomSpacing(0, after: errorView)
		stackView.addArrangedSubview(textLabel)
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}

	/// The  message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}

	/// The  message
	var text: String? {
		didSet {
			textLabel.text = text
		}
	}
}

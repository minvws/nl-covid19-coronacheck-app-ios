/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenEntryView: ScrollView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let buttonWidth: CGFloat = 212.0
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 54.0
		static let titleTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 34.0
		static let messageTopMargin: CGFloat = 24.0
		static let entryMargin: CGFloat = 16.0
		static let errorMargin: CGFloat = 8.0
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil).multiline()
	}()

	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The request token entry view
	let tokenEntryView: EntryView = {

		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The verification entry view
	let verificationEntryView: EntryView = {

		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let errorView: ErrorView = {

		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(tokenEntryView)
		contentView.addSubview(verificationEntryView)
		contentView.addSubview(errorView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.titleTopMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			tokenEntryView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			tokenEntryView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			tokenEntryView.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.margin
			),

			verificationEntryView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			verificationEntryView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			verificationEntryView.topAnchor.constraint(
				equalTo: tokenEntryView.bottomAnchor,
				constant: ViewTraits.entryMargin
			),

			errorView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			errorView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			errorView.topAnchor.constraint(
				equalTo: verificationEntryView.bottomAnchor,
				constant: ViewTraits.errorMargin
			)
		])
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The  message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}
}

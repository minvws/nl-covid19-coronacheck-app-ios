/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class BirthdateEntryView: ScrollView {

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

		return Label(title1: nil, montserrat: true).multiline()
	}()

	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The birthday day entry
	let dayEntryView: EntryView = {

		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.inputField.keyboardType = .numberPad
		return view
	}()

	/// The birthday month entry
	let monthEntryView: EntryView = {

		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.inputField.keyboardType = .numberPad
		return view
	}()

	/// The birthday year entry
	let yearEntryView: EntryView = {

		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.inputField.keyboardType = .numberPad
		return view
	}()

	let errorView: ErrorView = {

		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	/// the update button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	let entryStackView: UIStackView = {

		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.alignment = .leading
		stackView.distribution = .fill
//		stackView.spacing = 40
		return stackView
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		entryStackView.addArrangedSubview(dayEntryView)
		entryStackView.addArrangedSubview(monthEntryView)
		entryStackView.addArrangedSubview(yearEntryView)
		entryStackView.addArrangedSubview(UIView())
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(entryStackView)
		contentView.addSubview(errorView)
		contentView.addSubview(primaryButton)
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

			entryStackView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			entryStackView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			entryStackView.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.margin
			),

			dayEntryView.widthAnchor.constraint(greaterThanOrEqualToConstant: 40),
			monthEntryView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
			yearEntryView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),

			errorView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			errorView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			errorView.topAnchor.constraint(
				equalTo: entryStackView.bottomAnchor,
				constant: ViewTraits.errorMargin
			),

			// Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonWidth),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
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
			messageLabel.attributedText = .makeFromHtml(
				text: message,
				font: Theme.fonts.body,
				textColor: Theme.colors.dark
			)
		}
	}

	/// The button title
	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	var dayTitle: String? {
		didSet {
			dayEntryView.header = dayTitle
		}
	}

	var monthTitle: String? {
		didSet {
			monthEntryView.header = monthTitle
		}
	}

	var yearTitle: String? {
		didSet {
			yearEntryView.header = yearTitle
		}
	}
}

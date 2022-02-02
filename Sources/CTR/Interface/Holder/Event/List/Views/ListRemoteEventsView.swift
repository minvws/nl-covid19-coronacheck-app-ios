/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListRemoteEventsView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		enum Title {
			static let spacing: CGFloat = 24
			static let lineHeight: CGFloat = 26
			static let kerning: CGFloat = -0.26
		}

		enum Message {
			static let spacing: CGFloat = 32
		}

		enum Button {
			static let spacing: CGFloat = 8
		}
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()

	let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stack view for the event
	let eventStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 0
		return view
	}()

	/// The spinner
	let spinner: UIActivityIndicatorView = {

		let view = UIActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 13.0, *) {
			view.style = .large
		} else {
			view.style = .whiteLarge
		}
		view.color = Theme.colors.primary
		return view
	}()

	let somethingIsWrongButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		somethingIsWrongButton.touchUpInside(self, action: #selector(somethingIsWrongButtonTapped))
		stackView.distribution = .fill
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(spinner)

		stackView.addArrangedSubview(titleLabel)
		stackView.setCustomSpacing(ViewTraits.Title.spacing, after: titleLabel)
		stackView.addArrangedSubview(contentTextView)
		stackView.setCustomSpacing(ViewTraits.Message.spacing, after: contentTextView)
		stackView.addArrangedSubview(eventStackView)
		stackView.addArrangedSubview(somethingIsWrongButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}

	private func createSeparatorView() -> UIView {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.line
		return view
	}

	@objc func somethingIsWrongButtonTapped() {

		somethingIsWrongTappedCommand?()
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
	var message: String? {
		didSet {
			contentTextView.html(message)
		}
	}

	var somethingIsWrongTappedCommand: (() -> Void)?

	var somethingIsWrongButtonTitle: String? {
		didSet {
			somethingIsWrongButton.setTitle(somethingIsWrongButtonTitle, for: .normal)
			somethingIsWrongButton.isHidden = somethingIsWrongButtonTitle?.isEmpty ?? true
		}
	}

	func addSeparator() {

		let separator = createSeparatorView()
		eventStackView.addArrangedSubview(separator)

		NSLayoutConstraint.activate([
			separator.heightAnchor.constraint(equalToConstant: 1)
		])
	}

	func addEventItemView(_ eventView: RemoteEventItemView) {

		eventStackView.addArrangedSubview(eventView)
		addSeparator()
	}

	var hideForCapture: Bool = false {
		didSet {
			eventStackView.isHidden = hideForCapture
		}
	}

	func setEventStackVisibility(ishidden: Bool) {
		eventStackView.isHidden = ishidden
		if ishidden {
			stackView.setCustomSpacing(ViewTraits.Button.spacing, after: contentTextView)
		}
	}
}

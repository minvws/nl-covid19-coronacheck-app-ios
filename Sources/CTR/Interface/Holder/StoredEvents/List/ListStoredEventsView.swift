/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListStoredEventsView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		enum Title {
			static let spacing: CGFloat = 24
			static let lineHeight: CGFloat = 26
			static let kerning: CGFloat = -0.26
		}

		enum List {
			static let spacing: CGFloat = 40
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
	private let spinner: UIActivityIndicatorView = {

		let view = UIActivityIndicatorView()
		view.hidesWhenStopped = true
		view.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 13.0, *) {
			view.style = .large
		} else {
			view.style = .whiteLarge
		}
		view.color = C.primaryBlue()
		return view
	}()
	
	var shouldShowLoadingSpinner: Bool = false {
		didSet {
			if shouldShowLoadingSpinner {
				spinner.startAnimating()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					// After a short delay (otherwise it's never announced)
					UIAccessibility.post(notification: .layoutChanged, argument: self.spinner)
				}
			} else {
				spinner.stopAnimating()
			}
		}
	}

	let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
		stackView.distribution = .fill
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(spinner)

		stackView.addArrangedSubview(titleLabel)
		stackView.setCustomSpacing(ViewTraits.Title.spacing, after: titleLabel)
		stackView.addArrangedSubview(contentTextView)
		stackView.setCustomSpacing(ViewTraits.Button.spacing, after: contentTextView)
		stackView.addArrangedSubview(secondaryButton)
		stackView.setCustomSpacing(ViewTraits.List.spacing, after: secondaryButton)
		stackView.addArrangedSubview(eventStackView)
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
		view.backgroundColor = C.grey4()
		return view
	}

	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		set {
			titleLabel.attributedText = newValue?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
		get {
			titleLabel.attributedText?.string
		}
	}

	/// The message
	var message: String? {
		set {
			contentTextView.html(newValue)
		}
		get {
			contentTextView.attributedText?.string
		}
	}

	var secondaryButtonTappedCommand: (() -> Void)?

	var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
			secondaryButton.isHidden = secondaryButtonTitle?.isEmpty ?? true
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

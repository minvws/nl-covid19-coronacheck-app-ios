/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ListEventsView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22
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

		let button = Button(title: "", style: .tertiary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		somethingIsWrongButton.touchUpInside(self, action: #selector(somethingIsWrongButtonTapped))
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(spinner)

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextView)
		stackView.addArrangedSubview(eventStackView)
		stackView.addArrangedSubview(somethingIsWrongButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		// disable the bottom constraint of the scroll view, add our own
		bottomScrollViewConstraint?.isActive = false

		NSLayoutConstraint.activate([

			// Scroll View
			scrollView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor),

			spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
		
		setupPrimaryButton()
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
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
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

	func addVaccinationEventView(_ eventView: VaccinationEventView) {

		eventStackView.addArrangedSubview(eventView)
		addSeparator()
	}
}

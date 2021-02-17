/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let messageLineHeight: CGFloat = 22

		// Margins
		static let margin: CGFloat = 20.0
	}

	/// The internal scroll view
	private let scrollView: UIScrollView = {

		let scrollView = UIScrollView(frame: .zero)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()

	/// The stackview
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.margin
		return view
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The link label
	let linkLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(linkLabel)
		scrollView.addSubview(stackView)
		addSubview(scrollView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Scrollview
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

			// StackView
			stackView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2.0 * ViewTraits.margin
			),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			stackView.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: ViewTraits.margin
			),
			stackView.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	// MARK: Public Access

	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}

	/// Underline part ot the message
	/// - Parameter text: the text to underline
	func link(_ text: String?) {

		guard let text = text else {
			linkLabel.text = nil
			return
		}

		let attributedUnderlined = text.underline(underlined: text, with: Theme.colors.dark)
		linkLabel.attributedText = attributedUnderlined
	}
}

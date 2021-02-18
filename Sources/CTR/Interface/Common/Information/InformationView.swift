/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class InformationView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52

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

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil).multiline()
	}()

	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// the close button
	let closeButton: Button = {

		let button = Button(title: "", style: .secondary)
		button.setAttributedTitle(String.close.underline(underlined: .close), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		return button
	}()

	/// The bottom constraint
	var bottomConstraint: NSLayoutConstraint?

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		scrollView.addSubview(stackView)

		addSubview(scrollView)
		addSubview(closeButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Scrollview
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
//			scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

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
			),

			// Button
			closeButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			closeButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			closeButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			closeButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])

		bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
		bottomConstraint?.isActive = true
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

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

	var closeButtonIsHidden: Bool = true {
		didSet {
			closeButton.isHidden = closeButtonIsHidden
			if closeButtonIsHidden {
				bottomConstraint?.constant = 0
			} else {
				bottomConstraint?.constant = -ViewTraits.buttonHeight
			}
		}
	}
}

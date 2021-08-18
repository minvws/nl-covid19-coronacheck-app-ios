/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class MakeTestAppointmentView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 6
			static let edge: CGFloat = 20
		}
		
		enum Spacing {
			static let title: CGFloat = 24
			static let button: CGFloat = 48
		}
	}
	
	/// The stackview
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		return view
	}()
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title1: nil, montserrat: true).multiline().header()
	}()

	/// The message text
	private let messageTextView: TextView = {

		return TextView()
	}()
	
	let button: Button = {

		let button = Button(title: "Button", style: .roundedBlue)
		button.titleLabel?.font = Theme.fonts.bodySemiBold
		button.rounded = true
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentEdgeInsets = UIEdgeInsets(top: 15, left: 56, bottom: 15, right: 56)
		return button
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.setCustomSpacing(ViewTraits.Spacing.title, after: titleLabel)
		stackView.addArrangedSubview(messageTextView)

		addSubview(stackView)
		addSubview(button)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			stackView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.Margin.top
			),
			stackView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			stackView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.Margin.edge
			),
			
			button.centerXAnchor.constraint(
				equalTo: centerXAnchor
			),
			button.topAnchor.constraint(
				equalTo: stackView.bottomAnchor,
				constant: ViewTraits.Spacing.button
			),
			button.leadingAnchor.constraint(
				greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			button.trailingAnchor.constraint(
				lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.Margin.edge
			),
			button.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.Margin.edge
			)
		])
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The message
	var message: String? {
		didSet {
			messageTextView.attributedText = .makeFromHtml(
				text: message,
				font: Theme.fonts.body,
				textColor: Theme.colors.dark
			)
		}
	}
	
	/// The button title
	var buttonTitle: String? {
		didSet {
			button.setTitle(buttonTitle, for: .normal)
		}
	}
}

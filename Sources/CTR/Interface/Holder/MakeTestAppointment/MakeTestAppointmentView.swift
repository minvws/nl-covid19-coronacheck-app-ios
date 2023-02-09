/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class MakeTestAppointmentView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let title: CGFloat = 24
			static let button: CGFloat = 48
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
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

		return Button(title: "Button", style: .roundedBlue)
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
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
				equalTo: safeAreaLayoutGuide.topAnchor
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
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}

	/// The message
	var message: String? {
		didSet {
			self.messageTextView.attributedText = NSAttributedString.makeFromHtml(text: message, style: .bodyDark)
		}
	}
	
	/// The button title
	var buttonTitle: String? {
		didSet {
			button.setTitle(buttonTitle, for: .normal)
		}
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class FetchEventsView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22

		// Margins
//		static let margin: CGFloat = 20.0
//		static let buttonMargin: CGFloat = 54.0
//		static let titleTopMargin: CGFloat = 34.0
//		static let messageTopMargin: CGFloat = 24.0
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()

	private let messageLabel: Label = {

		return Label(body: nil).multiline()
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

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(spinner)

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(eventStackView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor)
		])

		setupPrimaryButton()
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
			messageLabel.attributedText = .makeFromHtml(text: message, font: Theme.fonts.body, textColor: Theme.colors.dark)
		}
	}
}

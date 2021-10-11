/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import WebKit

class InformationView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
	}

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
        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	/// The message label
	private let messageLabel: TextView = {
		return TextView()
	}()

	override func setupViews() {

		super.setupViews()
		titleLabel.textColor = Theme.colors.dark
		backgroundColor = Theme.colors.viewControllerBackground
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)

		addSubview(stackView)
	}

	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			stackView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor
			),
			stackView.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			),
			stackView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.margin
			)
		])
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
			messageLabel.attributedText = .makeFromHtml(text: message, style: .bodyDark)
		}
	}

	var linkTapHandler: ((URL) -> Void)? {
		didSet {
			guard let linkTapHandler = linkTapHandler else { return }
			messageLabel.linkTouched(handler: linkTapHandler)
		}
	}

	func handleScreenCapture(shouldHide: Bool) {
		messageLabel.isHidden = shouldHide
	}

}

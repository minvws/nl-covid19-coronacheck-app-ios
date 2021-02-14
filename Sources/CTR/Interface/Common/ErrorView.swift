/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ErrorView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		static let messageTopMargin: CGFloat = 4.0
	}

	/// The error image
	private let errorImageView: UIImageView = {
		let view = UIImageView(image: .error)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The title label
	private let errorLabel: Label = {

		return Label(subhead: nil)
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .clear
		errorLabel.textColor = Theme.colors.error
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(errorImageView)
		addSubview(errorLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Header
			errorImageView.leadingAnchor.constraint( equalTo: leadingAnchor),
			errorImageView.widthAnchor.constraint(equalToConstant: 12),
			errorImageView.heightAnchor.constraint(equalToConstant: 12),
			errorImageView.centerYAnchor.constraint(equalTo: errorLabel.centerYAnchor),

			// Title
			errorLabel.topAnchor.constraint(equalTo: topAnchor),
			errorLabel.leadingAnchor.constraint(
				equalTo: errorImageView.trailingAnchor,
				constant: 5
			),
			errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			errorLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: 0 // -ViewTraits.messageTopMargin
			)
		])
	}

	// MARK: Public Access

	/// The header
	var error: String? {
		didSet {
			errorLabel.text = error
		}
	}
}

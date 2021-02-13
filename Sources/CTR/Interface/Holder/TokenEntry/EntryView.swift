/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class EntryView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		static let headerMargin: CGFloat = 10.0
	}

	/// The header label
	private let headerLabel: Label = {

		return Label(caption1: nil)
	}()

	let inputField: UITextField = {

		let field = UITextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.returnKeyType = .send
		field.autocorrectionType = .no
		field.autocapitalizationType = .none
		return field
	}()

	private let lineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.line
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(headerLabel)
		addSubview(inputField)
		addSubview(lineView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Header
			headerLabel.topAnchor.constraint(equalTo: topAnchor),
			headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			headerLabel.bottomAnchor.constraint(
				equalTo: inputField.topAnchor,
				constant: -ViewTraits.headerMargin
			),

			inputField.leadingAnchor.constraint(equalTo: leadingAnchor),
			inputField.trailingAnchor.constraint(equalTo: trailingAnchor),
			inputField.bottomAnchor.constraint(equalTo: lineView.topAnchor),

			// Line
			lineView.heightAnchor.constraint(equalToConstant: 1),
			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	// MARK: Public Access

	/// The header
	var header: String? {
		didSet {
			headerLabel.text = header
		}
	}
}

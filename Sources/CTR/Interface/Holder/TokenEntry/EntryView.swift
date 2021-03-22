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

		// Dimensions
		static let headerHeight: CGFloat = 38.0
		static let infoHeight: CGFloat = 27.0
		static let inputHeight: CGFloat = 52.0
		static let lineHeight: CGFloat = 1.0

		// Margins
		static let margin: CGFloat = 20.0
	}

	/// The header label
	private let headerLabel: Label = {

		return Label(caption1SemiBold: nil)
	}()

	/// The info label
	private let infoLabel: Label = {

		return Label(subhead: nil)
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

	var infoConstraint: NSLayoutConstraint?

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		let tapGestureRecognizer = UITapGestureRecognizer(
			target: self,
			action: #selector(handleSingleTap(sender:))
		)
		self.addGestureRecognizer(tapGestureRecognizer)
		infoLabel.textColor = Theme.colors.launchGray
		infoLabel.isHidden = true
	}

	/// User tapped on the view
	/// - Parameter sender: the tapgesture
	@objc func handleSingleTap(sender: UITapGestureRecognizer) {

		inputField.becomeFirstResponder()
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(headerLabel)
		addSubview(infoLabel)
		addSubview(inputField)
		addSubview(lineView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Header
			headerLabel.topAnchor.constraint(equalTo: topAnchor),
			headerLabel.heightAnchor.constraint(equalToConstant: ViewTraits.headerHeight),
			headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

			// Info
			infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			infoLabel.bottomAnchor.constraint(equalTo: inputField.topAnchor),
			infoLabel.heightAnchor.constraint(equalToConstant: ViewTraits.infoHeight),

			inputField.leadingAnchor.constraint(equalTo: leadingAnchor),
			inputField.trailingAnchor.constraint(equalTo: trailingAnchor),
			inputField.bottomAnchor.constraint(equalTo: lineView.topAnchor),
			inputField.heightAnchor.constraint(equalToConstant: ViewTraits.inputHeight),

			// Line
			lineView.heightAnchor.constraint(equalToConstant: ViewTraits.lineHeight),
			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		infoConstraint = headerLabel.bottomAnchor.constraint(equalTo: inputField.topAnchor)
		infoConstraint?.isActive = true
	}

	// MARK: Public Access

	/// The header
	var header: String? {
		didSet {
			headerLabel.text = header
		}
	}

	/// The info
	var info: String? {
		didSet {
			infoLabel.text = info
			infoConstraint?.constant = info == nil ? 0 : -ViewTraits.infoHeight
			infoLabel.isHidden = info == nil
		}
	}
}

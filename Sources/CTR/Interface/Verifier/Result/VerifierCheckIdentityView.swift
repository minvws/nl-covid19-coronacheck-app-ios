/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierCheckIdentityView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let disclaimerSize: CGFloat = 60.0

		// Margins
		static let margin: CGFloat = 20.0
		static let identityTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 16.0 : 48.0
		static let identitySideMargin: CGFloat = UIDevice.current.isSmallScreen ? 20.0 : 48.0
		static let headerTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 16.0 : 40.0
	}

	/// The title label
	private let headerLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()

	private let disclaimerButton: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(.questionMark, for: .normal)
		button.titleLabel?.textColor = Theme.colors.dark
		return button
	}()

	private let identity: VerifierIdentityView = {
		let view = VerifierIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()

	override func setupViews() {

		super.setupViews()

		backgroundColor = Theme.colors.viewControllerBackground
		disclaimerButton.addTarget(
			self,
			action: #selector(disclaimerButtonTapped),
			for: .touchUpInside
		)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(headerLabel)
		addSubview(disclaimerButton)
		addSubview(identity)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		NSLayoutConstraint.activate([

			// Title
			headerLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.headerTopMargin
			),
			headerLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			headerLabel.trailingAnchor.constraint(equalTo: disclaimerButton.leadingAnchor),

			// Disclaimer button
			disclaimerButton.heightAnchor.constraint(
				equalToConstant: ViewTraits.disclaimerSize
			),
			disclaimerButton.widthAnchor.constraint(
				equalToConstant: ViewTraits.disclaimerSize
			),
			disclaimerButton.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			disclaimerButton.bottomAnchor.constraint(
				equalTo: headerLabel.bottomAnchor,
				constant: ViewTraits.margin
			),

			// Identity
			identity.topAnchor.constraint(
				equalTo: headerLabel.bottomAnchor,
				constant: ViewTraits.identityTopMargin
			),
			identity.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.identitySideMargin
			),
			identity.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.identitySideMargin
			),
			identity.bottomAnchor.constraint(
				lessThanOrEqualTo: bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	/// User tapped on the primary button
	@objc private func disclaimerButtonTapped() {

		disclaimerButtonTappedCommand?()
	}

	// Public Access

	var header: String? {
		didSet {
			headerLabel.text = header
		}
	}

	var firstNameHeader: String? {
		didSet {
			identity.firstNameHeader = firstNameHeader
		}
	}

	var firstName: String? {
		didSet {
			identity.firstName = firstName
		}
	}

	var lastNameHeader: String? {
		didSet {
			identity.lastNameHeader = lastNameHeader
		}
	}

	var lastName: String? {
		didSet {
			identity.lastName = lastName
		}
	}

	var dayOfBirthHeader: String? {
		didSet {
			identity.dayOfBirthHeader = dayOfBirthHeader
		}
	}

	var dayOfBirth: String? {
		didSet {
			identity.dayOfBirth = dayOfBirth
		}
	}

	var monthOfBirthHeader: String? {
		didSet {
			identity.monthOfBirthHeader = monthOfBirthHeader
		}
	}

	var monthOfBirth: String? {
		didSet {
			identity.monthOfBirth = monthOfBirth
		}
	}

	/// The user tapped on the disclaimer button
	var disclaimerButtonTappedCommand: (() -> Void)?
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierIdentityView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let spacing: CGFloat = 24.0
	}

	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .leading
		view.distribution = .fill
		view.spacing = ViewTraits.spacing
		return view
	}()

	let lastNameView: IdentityElementView = {
		let view = IdentityElementView()
		view.backgroundColor = .cyan
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let firstNameView: IdentityElementView = {
		let view = IdentityElementView()
		view.backgroundColor = .cyan
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let dayOfBirthView: IdentityElementView = {
		let view = IdentityElementView()
		view.backgroundColor = .cyan
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let monthOfBirthView: IdentityElementView = {
		let view = IdentityElementView()
		view.backgroundColor = .cyan
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

//	override func setupViews() {
//
//
//	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(lastNameView)
		stackView.addArrangedSubview(firstNameView)
		stackView.addArrangedSubview(dayOfBirthView)
		stackView.addArrangedSubview(monthOfBirthView)
		addSubview(stackView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		NSLayoutConstraint.activate([

			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor)
		])
	}
}

class VerifierCheckIdentityView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		static let identityTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 16.0 : 48.0
		static let identitySideMargin: CGFloat = UIDevice.current.isSmallScreen ? 20.0 : 48.0
		static let headerTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 16.0 : 40.0
	}

	/// The title label
	let headerLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()

	let disclaimerButton: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(.questionMark, for: .normal)
		button.titleLabel?.textColor = Theme.colors.dark
		return button
	}()

	let identity: VerifierIdentityView = {
		let view = VerifierIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .blue
		return view
	}()

	override func setupViews() {

		super.setupViews()

		backgroundColor = Theme.colors.secondary
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
			headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.margin),
			headerLabel.trailingAnchor.constraint(
				equalTo: disclaimerButton.leadingAnchor,
				constant: -8
			),

			// Disclaimer button
			disclaimerButton.heightAnchor.constraint(
				equalToConstant: 60
			),
			disclaimerButton.widthAnchor.constraint(
				equalToConstant: 60
			),
			disclaimerButton.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			disclaimerButton.bottomAnchor.constraint(
				equalTo: headerLabel.bottomAnchor,
				constant: 20
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
			)
		])
	}

	/// User tapped on the primary button
	@objc func disclaimerButtonTapped() {

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
			identity.firstNameView.header = firstNameHeader
		}
	}

	var firstName: String? {
		didSet {
			identity.firstNameView.body = firstName
		}
	}

	var lastNameHeader: String? {
		didSet {
			identity.lastNameView.header = lastNameHeader
		}
	}

	var lastName: String? {
		didSet {
			identity.lastNameView.body = lastName
		}
	}

	var dayOfBirthHeader: String? {
		didSet {
			identity.dayOfBirthView.header = dayOfBirthHeader
		}
	}

	var dayOfBirth: String? {
		didSet {
			identity.dayOfBirthView.body = dayOfBirth
		}
	}

	var monthOfBirthHeader: String? {
		didSet {
			identity.monthOfBirthView.header = monthOfBirthHeader
		}
	}

	var monthOfBirth: String? {
		didSet {
			identity.monthOfBirthView.body = monthOfBirth
		}
	}

	/// The user tapped on the disclaimer button
	var disclaimerButtonTappedCommand: (() -> Void)?
}

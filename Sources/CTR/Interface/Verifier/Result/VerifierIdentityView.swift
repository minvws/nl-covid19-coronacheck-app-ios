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
		static let borderHeight: CGFloat = 61.0
		static let borderWidth: CGFloat = 1.0
	}

	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.spacing
		return view
	}()

	private let horizontalStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .horizontal
		view.alignment = .leading
		view.distribution = .fillProportionally
		view.spacing = ViewTraits.spacing
		return view
	}()

	static func createIdentityElementView() -> IdentityElementView {

		return IdentityElementView(
			borderHeight: ViewTraits.borderHeight,
			borderWidth: ViewTraits.borderWidth,
			borderColor: Theme.colors.grey3,
			headerAlignment: .natural,
			bodyFont: Theme.fonts.title2
		)
	}

	private let lastNameView: IdentityElementView = {
		let view = createIdentityElementView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let firstNameView: IdentityElementView = {
		let view = createIdentityElementView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let dayOfBirthView: IdentityElementView = {
		let view = createIdentityElementView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let monthOfBirthView: IdentityElementView = {
		let view = createIdentityElementView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override func setupViews() {

		super.setupViews()
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(lastNameView)
		stackView.addArrangedSubview(firstNameView)
		horizontalStackView.addArrangedSubview(dayOfBirthView)
		horizontalStackView.addArrangedSubview(monthOfBirthView)
		stackView.addArrangedSubview(horizontalStackView)
		addSubview(stackView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		NSLayoutConstraint.activate([

			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.widthAnchor.constraint(equalTo: widthAnchor),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
		])
	}

	override func setupAccessibility() {

		super.setupAccessibility()

		accessibilityElements = [lastNameView, firstNameView, dayOfBirthView, monthOfBirthView]
	}

	// MARK: Public

	var firstNameHeader: String? {
		didSet {
			firstNameView.header = firstNameHeader
		}
	}

	var firstName: String? {
		didSet {
			firstNameView.body = firstName
		}
	}

	var lastNameHeader: String? {
		didSet {
			lastNameView.header = lastNameHeader
		}
	}

	var lastName: String? {
		didSet {
			lastNameView.body = lastName
		}
	}

	var dayOfBirthHeader: String? {
		didSet {
			dayOfBirthView.header = dayOfBirthHeader
		}
	}

	var dayOfBirth: String? {
		didSet {
			dayOfBirthView.body = dayOfBirth
		}
	}

	var monthOfBirthHeader: String? {
		didSet {
			monthOfBirthView.header = monthOfBirthHeader
		}
	}

	var monthOfBirth: String? {
		didSet {
			monthOfBirthView.body = monthOfBirth
		}
	}
}

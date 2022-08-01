/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

	private let lastNameView: IdentityElementView = {
		let view = IdentityElementView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let firstNameView: IdentityElementView = {
		let view = IdentityElementView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let dayOfBirthView: IdentityElementView = {
		let view = IdentityElementView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let monthOfBirthView: IdentityElementView = {
		let view = IdentityElementView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.embed(in: self)
		stackView.addArrangedSubview(lastNameView)
		stackView.addArrangedSubview(firstNameView)
		if traitCollection.preferredContentSizeCategory >= .extraLarge {
			stackView.addArrangedSubview(dayOfBirthView)
			stackView.addArrangedSubview(monthOfBirthView)
		} else {
			horizontalStackView.addArrangedSubview(dayOfBirthView)
			horizontalStackView.addArrangedSubview(monthOfBirthView)
			stackView.addArrangedSubview(horizontalStackView)
		}
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([

			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.widthAnchor.constraint(equalTo: widthAnchor)
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

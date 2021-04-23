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

	let birthDayView: IdentityElementView = {
		let view = IdentityElementView()
		view.backgroundColor = .cyan
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let birthMonthView: IdentityElementView = {
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
		stackView.addArrangedSubview(birthDayView)
		stackView.addArrangedSubview(birthMonthView)
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

	let identity: VerifierIdentityView = {
		let view = VerifierIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .blue
		return view
	}()

	override func setupViews() {

		super.setupViews()

	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(identity)

	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		NSLayoutConstraint.activate([

			identity.topAnchor.constraint(equalTo: topAnchor),
			identity.bottomAnchor.constraint(equalTo: bottomAnchor),
			identity.leadingAnchor.constraint(equalTo: leadingAnchor),
			identity.trailingAnchor.constraint(equalTo: trailingAnchor)

		])
	}

}

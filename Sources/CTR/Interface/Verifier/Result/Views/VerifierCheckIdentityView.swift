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
		
		enum Margin {
			static let edge: CGFloat = 20.0
			static let identityTop: CGFloat = UIDevice.current.isSmallScreen ? 16.0 : 48.0
			static let identitySide: CGFloat = UIDevice.current.isSmallScreen ? 20.0 : 48.0
			static let headerTop: CGFloat = 11.0 + UIApplication.shared.statusBarFrame.height
			static let headerBottom: CGFloat = 24.0
			static let headerSide: CGFloat = 80.0
		}
	}
	
	private let contentView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()

	/// The title label
	private let headerLabel: Label = {

		let label = Label(bodySemiBold: nil).multiline()
		label.textColor = Theme.colors.dark
		return label
	}()

	private let identity: VerifierIdentityView = {
		let view = VerifierIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(headerLabel)
		addSubview(contentView)
		contentView.addSubview(identity)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		NSLayoutConstraint.activate([
			
			// Title
			headerLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.Margin.headerTop
			),
			headerLabel.leadingAnchor.constraint(
				greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.Margin.headerSide
			),
			headerLabel.trailingAnchor.constraint(
				lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.Margin.headerSide
			),
			headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			
			contentView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: ViewTraits.Margin.headerBottom),
			contentView.leftAnchor.constraint(equalTo: leftAnchor),
			contentView.rightAnchor.constraint(equalTo: rightAnchor),
			contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

			// Identity
			identity.topAnchor.constraint(
				equalTo: contentView.topAnchor,
				constant: ViewTraits.Margin.identityTop
			),
			identity.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.Margin.identitySide
			),
			identity.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.Margin.identitySide
			),
			identity.bottomAnchor.constraint(
				lessThanOrEqualTo: contentView.bottomAnchor,
				constant: -ViewTraits.Margin.edge
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

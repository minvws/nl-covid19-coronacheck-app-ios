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
			static let headerTop: CGFloat = 32.0
			static let headerBottom: CGFloat = 24.0
			static let headerSide: CGFloat = 80.0
		}
	}
	
	/// The scrollview
	private let scrollView: UIScrollView = {

		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()
	
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
		label.textAlignment = .center
		return label
	}()

	private let identity: VerifierIdentityView = {
		
		let view = VerifierIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()
	
	private let footerButtonView: VerifierFooterButtonView = {
		
		let footerView = VerifierFooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(headerLabel)
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(contentView)
		contentView.addSubview(identity)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		NSLayoutConstraint.activate([
			
			// Title
			headerLabel.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: -ViewTraits.Margin.headerTop
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
			
			scrollView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: ViewTraits.Margin.headerBottom),
			scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			scrollView.bottomAnchor.constraint(equalTo: footerButtonView.topAnchor),
			
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
			contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

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
				equalTo: contentView.bottomAnchor,
				constant: -ViewTraits.Margin.edge
			),
			
			footerButtonView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
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

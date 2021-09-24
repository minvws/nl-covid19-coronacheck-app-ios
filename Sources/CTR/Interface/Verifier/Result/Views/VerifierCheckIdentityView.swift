/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierCheckIdentityView: BaseView {

	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let edge: CGFloat = 20.0
			static let identityTop: CGFloat = UIDevice.current.isSmallScreen ? 16.0 : 48.0
			static let identitySide: CGFloat = UIDevice.current.isSmallScreen ? 20.0 : 48.0
			static let headerTop: CGFloat = 32.0
			static let headerBottom: CGFloat = 24.0
			static let headerSide: CGFloat = 80.0
		}
		enum Spacing {
			static let identityToSecondaryButton: CGFloat = 32
		}
	}
	
	/// The scrollview
	private let scrollView: UIScrollView = {

		let view = UIScrollView()
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

	private let identityView: VerifierIdentityView = {
		
		let view = VerifierIdentityView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()
	
	let footerButtonView: FooterButtonView = {
		
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()
	
	let secondaryButton: Button = {
		let button = Button(style: .textLabelBlue)
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	/// Setup the views
	override func setupViews() {
		super.setupViews()
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(headerLabel)
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(identityView)
		scrollView.addSubview(secondaryButton)
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
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.Margin.headerSide
			),
			headerLabel.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.Margin.headerSide
			),
			
			// Scroll view
			scrollView.topAnchor.constraint(
				equalTo: headerLabel.bottomAnchor,
				constant: ViewTraits.Margin.headerBottom
			),
			scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			scrollView.bottomAnchor.constraint(equalTo: footerButtonView.topAnchor),

			// Identity
			identityView.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: ViewTraits.Margin.identityTop
			),
			identityView.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.identitySide
			),
			identityView.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.Margin.identitySide
			),
			identityView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -ViewTraits.Margin.identitySide * 2
			),
			
			// Secondary button
			secondaryButton.topAnchor.constraint(
				equalTo: identityView.bottomAnchor,
				constant: ViewTraits.Spacing.identityToSecondaryButton
			),
			secondaryButton.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.identitySide
			),
			secondaryButton.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.Margin.identitySide
			),
			secondaryButton.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.Margin.edge
			),
			
			// Footer view
			footerButtonView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	// MARK: - Public Access

	var header: String? {
		didSet {
			headerLabel.text = header
		}
	}

	var firstNameHeader: String? {
		didSet {
			identityView.firstNameHeader = firstNameHeader
		}
	}

	var firstName: String? {
		didSet {
			identityView.firstName = firstName
		}
	}

	var lastNameHeader: String? {
		didSet {
			identityView.lastNameHeader = lastNameHeader
		}
	}

	var lastName: String? {
		didSet {
			identityView.lastName = lastName
		}
	}

	var dayOfBirthHeader: String? {
		didSet {
			identityView.dayOfBirthHeader = dayOfBirthHeader
		}
	}

	var dayOfBirth: String? {
		didSet {
			identityView.dayOfBirth = dayOfBirth
		}
	}

	var monthOfBirthHeader: String? {
		didSet {
			identityView.monthOfBirthHeader = monthOfBirthHeader
		}
	}

	var monthOfBirth: String? {
		didSet {
			identityView.monthOfBirth = monthOfBirth
		}
	}
	
	var primaryTitle: String? {
		didSet {
			footerButtonView.primaryTitle = primaryTitle
		}
	}
	
	var secondaryTitle: String? {
		didSet {
			secondaryButton.title = secondaryTitle
		}
	}
}

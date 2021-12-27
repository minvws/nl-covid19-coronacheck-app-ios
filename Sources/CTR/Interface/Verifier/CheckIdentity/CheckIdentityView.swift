/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class CheckIdentityView: BaseView {

	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let edge: CGFloat = 20.0
			static let identityTop: CGFloat = UIDevice.current.isSmallScreen ? 16.0 : 48.0
			static let identitySide: CGFloat = UIDevice.current.isSmallScreen ? 20.0 : 48.0
			static let scrollViewTop: CGFloat = 12
		}
		enum Spacing {
			static let identityToCheckIdentityLabel: CGFloat = 24
			static let secondaryToPrimaryButton: CGFloat = 16
		}
		enum Button {
			static let height: CGFloat = 52
		}
		enum Label {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}
	}
	
	/// The scrollview
	private let scrollView: UIScrollView = {

		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
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
		
		return Button(style: .roundedBlueBorder)
	}()
	
	private let dccFlagLabel: Label = {
		
		let label = Label(title1: nil)
		label.textColor = Theme.colors.secondaryText
		label.textAlignment = .center
		return label
	}()
	
	private let dccScannedLabel: Label = {
		
		return Label(subheadHeavyBold: nil).multiline()
	}()
	
	private let checkIdentityLabel: Label = {
		
		return Label(subhead: nil).multiline()
	}()
	
	private let labelStackView: UIStackView = {
		
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		return stackView
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	/// Setup the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.grey5
		footerButtonView.primaryButton.style = .roundedBlueImage
		secondaryButton.touchUpInside(self, action: #selector(readMoreTapped))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(identityView)
		scrollView.addSubview(labelStackView)
		footerButtonView.buttonStackView.insertArrangedSubview(secondaryButton, at: 0)
		labelStackView.addArrangedSubview(dccFlagLabel)
		labelStackView.addArrangedSubview(dccScannedLabel)
		labelStackView.addArrangedSubview(checkIdentityLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			// Scroll view
			scrollView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.Margin.scrollViewTop
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
			
			// Check identity label
			labelStackView.topAnchor.constraint(
				equalTo: identityView.bottomAnchor,
				constant: ViewTraits.Spacing.identityToCheckIdentityLabel
			),
			labelStackView.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.identitySide
			),
			labelStackView.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.Margin.identitySide
			),
			labelStackView.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.Margin.edge
			),
			labelStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			
			// Secondary button
			secondaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.Button.height),
			
			// Footer view
			footerButtonView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	@objc private func readMoreTapped() {
		
		readMoreTappedCommand?()
	}

	// MARK: - Public Access

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
	
	var primaryButtonIcon: UIImage? {
		didSet {
			footerButtonView.primaryButton.setImage(primaryButtonIcon, for: .normal)
		}
	}
	
	var checkIdentity: String? {
		didSet {
			checkIdentityLabel.attributedText = checkIdentity?.setLineHeight(ViewTraits.Label.lineHeight,
																			 alignment: .center,
																			 kerning: ViewTraits.Label.kerning,
																			 textColor: Theme.colors.secondaryText)
		}
	}
	
	var dccFlag: String? {
		didSet {
			dccFlagLabel.text = dccFlag
		}
	}
	
	var dccScanned: String? {
		didSet {
			dccScannedLabel.attributedText = dccScanned?.setLineHeight(ViewTraits.Label.lineHeight,
																	   alignment: .center,
																	   kerning: ViewTraits.Label.kerning,
																	   textColor: Theme.colors.secondaryText)
		}
	}
	
	/// The user tapped on the primary button
	var identityVerifiedTappedCommand: (() -> Void)? {
		didSet {
			footerButtonView.primaryButtonTappedCommand = identityVerifiedTappedCommand
		}
	}

	/// The user tapped on the secondary button
	var readMoreTappedCommand: (() -> Void)?
}
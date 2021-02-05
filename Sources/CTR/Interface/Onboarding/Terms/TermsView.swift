/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TermsView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22
		
		// Margins
		static let margin: CGFloat = 20.0
		static let ribbonOffset: CGFloat = 15.0
		static let buttonWidth: CGFloat = 182.0
		static let pageControlMargin: CGFloat = 12.0
	}
	
	private let ribbonView: UIImageView = {
		
		let view = UIImageView(image: .ribbon)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title1: nil).multiline()
	}()
	
	/// The message label
	let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()

	/// The message label
	let agreeLabel: Label = {

		return Label(body: nil).multiline()
	}()

	let toggleView: UISwitch = {

		let view = UISwitch()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.onTintColor = Theme.colors.primary
		view.accessibilityIdentifier = "ToggleView"
		return view
	}()
	
	/// the update button
	let primaryButton: Button = {
		
		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = .white
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(ribbonView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(agreeLabel)
		addSubview(toggleView)
		addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			// Ribbon
			ribbonView.centerXAnchor.constraint(equalTo: centerXAnchor),
			ribbonView.topAnchor.constraint(
				equalTo: topAnchor,
				constant: UIDevice.current.hasNotch ? 0 : -ViewTraits.ribbonOffset
			),

			// Title
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.margin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Agree
			agreeLabel.leadingAnchor.constraint(
				equalTo: toggleView.trailingAnchor,
				constant: ViewTraits.margin
			),
			agreeLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			agreeLabel.centerYAnchor.constraint(
				equalTo: toggleView.centerYAnchor,
				constant: -ViewTraits.margin
			),

			// Toggle
			toggleView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),

			toggleView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: ViewTraits.margin),
			toggleView.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -ViewTraits.margin),
			toggleView.heightAnchor.constraint(equalToConstant: 50),

			// Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonWidth),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	// MARK: Public Access

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The onboarding message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}

	/// The onboarding message
	var agree: String? {
		didSet {
			agreeLabel.attributedText = agree?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenEntryView: ScrolledStackWithButtonView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22
		static let gradientHeight: CGFloat = 30.0
		
		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 54.0
		static let titleTopMargin: CGFloat = 24.0
		static let messageTopMargin: CGFloat = 24.0
		static let entryMargin: CGFloat = 16.0
		static let errorMargin: CGFloat = 8.0
	}
	
	/// The title label
	private let titleLabel: Label = {
		
        return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	/// The message label
	private let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()
	
	/// The request token entry view
	let tokenEntryView: EntryView = {
		
		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.inputField.autocapitalizationType = .allCharacters
		if #available(iOS 12.0, *) {
			view.inputField.textContentType = .oneTimeCode
		}
		return view
	}()
	
	/// The verification entry view
	let verificationEntryView: EntryView = {
		
		let view = EntryView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.inputField.autocapitalizationType = .allCharacters
		view.inputField.keyboardType = .numberPad
		if #available(iOS 12.0, *) {
			view.inputField.textContentType = .oneTimeCode
		}
		
		return view
	}()
	
	let errorView: ErrorView = {
		
		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()
	
	/// The message label
	let textLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	let resendVerificationCodeButton: Button = {

		let button = Button(title: "Button 1", style: .tertiary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()

	let userNeedsATokenButton: Button = {
		
		let button = Button(title: "", style: .tertiary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	private let spacer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()
	
	/// Setup all the views
	override func setupViews() {
		
		super.setupViews()
		stackView.distribution = .fill
		resendVerificationCodeButton.touchUpInside(self, action: #selector(resendVerificationCodeButtonTapped))
		userNeedsATokenButton.touchUpInside(self, action: #selector(userNeedsATokenButtonTapped))
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)

		stackView.addArrangedSubview(tokenEntryView)
		stackView.setCustomSpacing(8, after: tokenEntryView)

		stackView.addArrangedSubview(userNeedsATokenButton)
		stackView.setCustomSpacing(0, after: userNeedsATokenButton)

		stackView.addArrangedSubview(verificationEntryView)
		stackView.setCustomSpacing(8, after: verificationEntryView)

		stackView.addArrangedSubview(errorView)
		stackView.setCustomSpacing(0, after: errorView)

		stackView.addArrangedSubview(textLabel)
		stackView.setCustomSpacing(8, after: textLabel)

		stackView.addArrangedSubview(resendVerificationCodeButton)
		stackView.addArrangedSubview(spacer)
	}
	
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			spacer.heightAnchor.constraint(equalTo: primaryButton.heightAnchor, multiplier: 2.0)
		])

		setupPrimaryButton(useFullWidth: {
			switch traitCollection.preferredContentSizeCategory {
				case .unspecified: return true
				case let size where size > .extraLarge: return true
				default: return false
			}
		}())
	}

	@objc func userNeedsATokenButtonTapped() {

		userNeedsATokenButtonTappedCommand?()
	}

	@objc func resendVerificationCodeButtonTapped() {
		
		resendVerificationCodeButtonTappedCommand?()
	}
	
	// MARK: Public Access
	
	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}
	
	/// The message
	var message: String? {
		didSet {
			if let message = message {
				messageLabel.attributedText = message.setLineHeight(ViewTraits.messageLineHeight)
				messageLabel.isHidden = false
			} else {
				messageLabel.isHidden = true
			}
		}
	}
	
	var text: String? {
		didSet {
			textLabel.text = text
		}
	}
	
	var userNeedsATokenButtonTitle: String? {
		didSet {
			userNeedsATokenButton.setTitle(userNeedsATokenButtonTitle, for: .normal)
		}
	}
	var resendVerificationCodeButtonTitle: String? {
		didSet {
			resendVerificationCodeButton.setTitle(resendVerificationCodeButtonTitle, for: .normal)
		}
	}
	
	var resendVerificationCodeButtonTappedCommand: (() -> Void)?

	var userNeedsATokenButtonTappedCommand: (() -> Void)?
	
	var tokenEntryFieldPlaceholder: String? {
		didSet {
			tokenEntryView.inputField.attributedPlaceholder = tokenEntryFieldPlaceholder.map {
				NSAttributedString(
					string: $0,
					attributes: [NSAttributedString.Key.foregroundColor: Theme.colors.grey1]
				)
			}
		}
	}
	
	var verificationEntryFieldPlaceholder: String? {
		didSet {
			verificationEntryView.inputField.attributedPlaceholder = verificationEntryFieldPlaceholder.map {
				NSAttributedString(
					string: $0,
					attributes: [NSAttributedString.Key.foregroundColor: Theme.colors.grey1]
				)
			}
		}
	}

	var fieldErrorMessage: String? {
		didSet {
			if let message = fieldErrorMessage {
				errorView.error = message
				errorView.isHidden = false
				textLabel.isHidden = true
			} else {
				errorView.isHidden = true
			}
		}
	}
}

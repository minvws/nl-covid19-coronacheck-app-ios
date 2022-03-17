/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PaperProofInputCouplingCodeView: ScrolledStackWithButtonView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22
		static let gradientHeight: CGFloat = 30.0
		static let textLineHeight: CGFloat = 18
		static let textKerning: CGFloat = -0.24
		
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
	
	/// The header label
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
	
	let errorView: ErrorView = {
		
		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	let userNeedsATokenButton: Button = {
		
		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	/// Setup all the views
	override func setupViews() {
		
		super.setupViews()
		stackView.distribution = .fill
		userNeedsATokenButton.touchUpInside(self, action: #selector(userNeedsATokenButtonTapped))
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)

		stackView.addArrangedSubview(tokenEntryView)
		stackView.setCustomSpacing(8, after: tokenEntryView)

		stackView.addArrangedSubview(errorView)
		stackView.setCustomSpacing(16, after: errorView)

		stackView.addArrangedSubview(userNeedsATokenButton)
		stackView.setCustomSpacing(ViewTraits.margin, after: userNeedsATokenButton)
	}

	@objc func userNeedsATokenButtonTapped() {

		userNeedsATokenButtonTappedCommand?()
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
	
	/// The header
	var header: String? {
		didSet {
			if let header = header {
				messageLabel.attributedText = header.setLineHeight(ViewTraits.messageLineHeight)
				messageLabel.isHidden = false
			} else {
				messageLabel.isHidden = true
			}
		}
	}
	
	var userNeedsATokenButtonTitle: String? {
		didSet {
			userNeedsATokenButton.setTitle(userNeedsATokenButtonTitle, for: .normal)
		}
	}

	var userNeedsATokenButtonTappedCommand: (() -> Void)?
	
	var tokenEntryFieldPlaceholder: String? {
		didSet {
			tokenEntryView.inputField.attributedPlaceholder = tokenEntryFieldPlaceholder.map {
				NSAttributedString(
					string: $0,
					attributes: [NSAttributedString.Key.foregroundColor: C.grey1()!]
				)
			}
		}
	}

	var fieldErrorMessage: String? {
		didSet {
			if let header = fieldErrorMessage {
				errorView.error = header
				errorView.isHidden = false
				stackView.setCustomSpacing(8, after: tokenEntryView)
			} else {
				stackView.setCustomSpacing(16, after: tokenEntryView)
				errorView.isHidden = true
			}
		}
	}
}

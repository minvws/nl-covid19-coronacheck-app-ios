/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PaperProofStartView: ScrolledStackWithButtonView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		
		enum Spacing {
			static let title: CGFloat = 24
			static let messageToItems: CGFloat = 40
			static let items: CGFloat = 40
			static let itemsToButton: CGFloat = 40
		}
	}
	
	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	/// The message text
	private let messageTextView: TextView = {

		return TextView()
	}()

	/// The stack view for the menu items
	let itemStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.Spacing.items
		return view
	}()

	let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .leading
		return button
	}()

	override func setupViews() {

		super.setupViews()
		
		backgroundColor = C.white()
		secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
		
		stackView.distribution = .fill
	}
	
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		// Elements
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageTextView)
		stackView.addArrangedSubview(itemStackView)
		stackView.addArrangedSubview(secondaryButton)

		// Spacing
		stackView.setCustomSpacing(ViewTraits.Spacing.title, after: titleLabel)
		stackView.setCustomSpacing(ViewTraits.Spacing.messageToItems, after: messageTextView)
		stackView.setCustomSpacing(ViewTraits.Spacing.itemsToButton, after: itemStackView)
	}

	// MARK: - Callbacks

	@objc func secondaryButtonTapped() {

		secondaryButtonCommand?()
	}
	
	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	/// The message
	var message: String? {
		didSet {
			messageTextView.attributedText = .makeFromHtml(text: message, style: .bodyDark)
		}
	}

	var secondaryButtonCommand: (() -> Void)?
}

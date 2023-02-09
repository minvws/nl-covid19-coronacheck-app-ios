/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class PaperProofStartScanningView: ScrolledStackWithButtonView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		
		enum Spacing {
			static let title: CGFloat = 24
			static let message: CGFloat = 16
			static let icon: CGFloat = 40
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

	private let iconView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .center
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
		
		stackView.addArrangedSubview(titleLabel)
		stackView.setCustomSpacing(ViewTraits.Spacing.title, after: titleLabel)
		stackView.addArrangedSubview(messageTextView)
		stackView.setCustomSpacing(ViewTraits.Spacing.message, after: messageTextView)
		stackView.addArrangedSubview(secondaryButton)
		stackView.setCustomSpacing(ViewTraits.Spacing.icon, after: secondaryButton)
		stackView.addArrangedSubview(iconView)
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
			NSAttributedString.makeFromHtml(
				text: message,
				style: NSAttributedString.HTMLStyle(
					font: Fonts.body,
					textColor: C.black()!,
					paragraphSpacing: 0
				)
			) {
				self.messageTextView.attributedText = $0
			}
		}
	}

	var icon: UIImage? {
		didSet {
			iconView.image = icon
		}
	}

	var secondaryButtonCommand: (() -> Void)?
}

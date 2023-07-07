/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Resources

final public class ContentWithImageView: ScrolledStackWithButtonView {
	
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

	public let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	public override func setupViews() {
		
		super.setupViews()
		
		backgroundColor = C.white()
		secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
		stackView.distribution = .fill
	}
	
	override public func setupViewHierarchy() {
		
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

	@objc public func secondaryButtonTapped() {

		secondaryButtonCommand?()
	}
	
	// MARK: Public Access

	/// The title
	public var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	/// The message
	public var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(
				text: message,
				style: .bodyDarkNoParagraphSpacing
			) {
				self.messageTextView.attributedText = $0
			}
		}
	}

	public var image: UIImage? {
		didSet {
			iconView.image = image
		}
	}
	
	public var secondaryTitle: String? {
		didSet {
			secondaryButton.title = secondaryTitle
			if secondaryTitle == nil {
				// Hide secondary button, but increase the spacing
				secondaryButton.isHidden = true
				stackView.setCustomSpacing(ViewTraits.Spacing.icon, after: messageTextView)
			} else {
				// Show the secondary button
				secondaryButton.isHidden = false
				stackView.setCustomSpacing(ViewTraits.Spacing.message, after: messageTextView)
			}
		}
	}

	public var secondaryButtonCommand: (() -> Void)?
}

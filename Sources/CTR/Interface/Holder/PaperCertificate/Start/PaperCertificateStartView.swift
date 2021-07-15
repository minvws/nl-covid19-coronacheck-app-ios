/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PaperCertificateStartView: ScrolledStackWithButtonView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Title {
			static let lineHeight: CGFloat = 26
			static let kerning: CGFloat = -0.26
		}
		
		enum Spacing {
			static let title: CGFloat = 24
			static let messageLabel: CGFloat = 44
		}
	}
	
	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()
	
	private let highlightedMessageLabel = RoundedLabel()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		
		stackView.distribution = .fill
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(highlightedMessageLabel)
		stackView.setCustomSpacing(ViewTraits.Spacing.title, after: titleLabel)
		stackView.setCustomSpacing(ViewTraits.Spacing.messageLabel, after: messageLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		setupPrimaryButton()
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
			messageLabel.attributedText = .makeFromHtml(text: message,
														font: Theme.fonts.body,
														textColor: Theme.colors.dark)
		}
	}
	
	/// The highlighted message shown in rounded label
	var highlightedMessage: String? {
		didSet {
			highlightedMessageLabel.message = highlightedMessage
		}
	}
}
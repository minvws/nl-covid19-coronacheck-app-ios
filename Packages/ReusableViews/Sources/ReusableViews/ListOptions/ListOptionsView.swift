/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Resources

public class ListOptionsView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}

		enum Message {
			static let lineHeight: CGFloat = 22
		}
		
		enum StackView {
			static let spacing: CGFloat = 24.0
			static let verticalMargin: CGFloat = 32.0
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

	private let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .leading
		return button
	}()

	/// The stack view for the content
	public let optionStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.StackView.spacing
		view.accessibilityIdentifier = "Options Stack View"
		return view
	}()

	/// Setup all the views
	override open func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		stackView.distribution = .fill
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
	}

	/// Setup the hierarchy
	override open func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.setCustomSpacing(ViewTraits.StackView.verticalMargin, after: messageLabel)
		stackView.addArrangedSubview(optionStackView)
		stackView.addArrangedSubview(secondaryButton)
	}

	override open func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// StackView
			optionStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			optionStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
		])
	}

	/// User tapped on the primary button
	@objc public func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The  title
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
			if let message {
				messageLabel.attributedText = message.setLineHeight(ViewTraits.Message.lineHeight)
				messageLabel.isHidden = false
			} else {
				messageLabel.isHidden = true
			}
		}
	}

	public var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.title = secondaryButtonTitle
			secondaryButton.isAccessibilityElement = secondaryButtonTitle != nil
			secondaryButton.isHidden = secondaryButtonTitle == nil
		}
	}

	public var secondaryButtonTappedCommand: (() -> Void)?
}

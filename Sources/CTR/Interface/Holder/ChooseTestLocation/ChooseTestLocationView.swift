/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseTestLocationView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22

		// Margins
		static let spacing: CGFloat = 24.0
		static let stackviewVerticalMargin: CGFloat = 32.0
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()

	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	private let noTestButton: Button = {

		let button = Button(title: "Button 1", style: .tertiary)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .leading
		return button
	}()

	/// The stack view for the content
	let buttonsStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.spacing
		view.accessibilityIdentifier = "Buttons Stack View"
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		stackView.distribution = .fill
		noTestButton.touchUpInside(self, action: #selector(noTestButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.setCustomSpacing(ViewTraits.stackviewVerticalMargin, after: messageLabel)
		stackView.addArrangedSubview(buttonsStackView)
		stackView.addArrangedSubview(noTestButton)
	}

	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// StackView
			buttonsStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			buttonsStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
		])
	}

	/// User tapped on the primary button
	@objc func noTestButtonTapped() {

		noTestButtonTappedCommand?()
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

	var noTestTitle: String = "" {
		didSet {
			noTestButton.setTitle(noTestTitle, for: .normal)
		}
	}

	var noTestButtonTappedCommand: (() -> Void)?
}

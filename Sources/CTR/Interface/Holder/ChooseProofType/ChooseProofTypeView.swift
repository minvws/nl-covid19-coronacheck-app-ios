/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ChooseProofTypeView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		enum Title {
			static let lineHeight: CGFloat = 26
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

	/// The stack view for the content
	let buttonsStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.StackView.spacing
		view.accessibilityIdentifier = "Buttons Stack View"
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		stackView.distribution = .fill
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.setCustomSpacing(ViewTraits.StackView.verticalMargin, after: messageLabel)
		stackView.addArrangedSubview(buttonsStackView)
	}

	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			// StackView
			buttonsStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			buttonsStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
		])
	}

	// MARK: Public Access

	/// The  title
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
			if let message = message {
				messageLabel.attributedText = message.setLineHeight(ViewTraits.Message.lineHeight)
				messageLabel.isHidden = false
			} else {
				messageLabel.isHidden = true
			}
		}
	}
}

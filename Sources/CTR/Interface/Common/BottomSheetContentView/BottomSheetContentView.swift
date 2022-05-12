/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import WebKit

class BottomSheetContentView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		
		// Title
		static let lineHeight: CGFloat = 32.0
		static let kerning: CGFloat = -0.26
	}

	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.margin
		return view
	}()
	
	private let titleLabel: Label = {
        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	private let messageLabel: TextView = {
		return TextView()
	}()

	let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	override func setupViews() {

		super.setupViews()
		titleLabel.textColor = C.black()
		backgroundColor = C.white()
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(secondaryButton)
		
		addSubview(stackView)
	}

	override func setupViewConstraints() {

		super.setupViewConstraints()

		stackView.embed(
			in: safeAreaLayoutGuide,
			insets: UIEdgeInsets(top: 0, left: ViewTraits.margin, bottom: ViewTraits.margin, right: ViewTraits.margin)
		)
	}
	
	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	// MARK: Public Access

	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.lineHeight,
															 kerning: ViewTraits.kerning)
		}
	}

	var body: String? {
		didSet {
			messageLabel.attributedText = .makeFromHtml(text: body, style: .bodyDark)
		}
	}

	var messageLinkTapHandler: ((URL) -> Void)? {
		didSet {
			guard let linkTapHandler = messageLinkTapHandler else { return }
			messageLabel.linkTouched(handler: linkTapHandler)
		}
	}
	
	var secondaryButtonTappedCommand: (() -> Void)?

	/// The title for the secondary white/blue button
	var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
			secondaryButton.isHidden = secondaryButtonTitle?.isEmpty ?? true
		}
	}

	func handleScreenCapture(shouldHide: Bool) {
		messageLabel.isHidden = shouldHide
	}
}

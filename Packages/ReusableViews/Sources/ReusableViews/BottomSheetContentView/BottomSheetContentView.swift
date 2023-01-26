/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import WebKit
import Shared

public class BottomSheetContentView: BaseView {

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

	public let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	override open func setupViews() {

		super.setupViews()
		titleLabel.textColor = C.black()
		backgroundColor = C.white()
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
	}

	override open func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.embed(
			in: safeAreaLayoutGuide,
			insets: UIEdgeInsets(top: 0, left: ViewTraits.margin, bottom: ViewTraits.margin, right: ViewTraits.margin)
		)
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(secondaryButton)
	}
	
	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	// MARK: Public Access

	public var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.lineHeight,
															 kerning: ViewTraits.kerning)
		}
	}

	public var body: String? {
		didSet {
			messageLabel.attributedText = .makeFromHtml(text: body, style: .bodyDark)
		}
	}

	public var messageLinkTapHandler: ((URL) -> Void)? {
		didSet {
			messageLabel.linkTouchedHandler = messageLinkTapHandler
		}
	}
	
	public var secondaryButtonTappedCommand: (() -> Void)?

	/// The title for the secondary white/blue button
	public var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
			secondaryButton.isHidden = secondaryButtonTitle?.isEmpty ?? true
		}
	}

	public func handleScreenCapture(shouldHide: Bool) {
		messageLabel.isHidden = shouldHide
	}
}

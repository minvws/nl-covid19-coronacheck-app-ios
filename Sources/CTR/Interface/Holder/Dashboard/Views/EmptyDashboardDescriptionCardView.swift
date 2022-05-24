/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class EmptyDashboardDescriptionCardView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Spacing {
			static let messageToButton: CGFloat = 16
		}
	}
	
	let contentTextView = TextView()
	
	private let button: Button = {
		let button = Button(style: .textLabelBlue)
		button.contentHorizontalAlignment = .left
		return button
	}()
		
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		return stackView
	}()
	
	// MARK: - Lifecycle

	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
		button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		stackView.embed(in: self)
		stackView.addArrangedSubview(contentTextView)
	}
	
	/// The message
	var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(
				text: self.message,
				style: NSAttributedString.HTMLStyle(
					font: Fonts.body,
					textColor: C.black()!,
					paragraphSpacing: 0
				)
			) {
				self.contentTextView.attributedText = $0
			}
		}
	}
	
	/// The button title
	var buttonTitle: String? {
		didSet {
			guard button.title?.isEmpty == true, let buttonTitle = buttonTitle else { return }
			button.title = buttonTitle
			stackView.insertArrangedSubview(button, at: 1)
			stackView.setCustomSpacing(ViewTraits.Spacing.messageToButton, after: contentTextView)
		}
	}
	
	/// User tapped on the button
	@objc func onTap() {

		buttonTappedCommand?()
	}

	/// The user tapped on the button
	var buttonTappedCommand: (() -> Void)?
}

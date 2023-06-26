/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Resources

final class EmptyDashboardDescriptionCardView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Spacing {
			static let messageToButton: CGFloat = 16
		}
	}
	
	private var contentTextView = TextView()
	
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
				style: .bodyDarkNoParagraphSpacing
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
	
	/// User tapped on a link in the contentTextView text
	var linkTouchedHandler: ((URL) -> Void)? {
		didSet {
			contentTextView.linkTouchedHandler = linkTouchedHandler
		}
	}
}

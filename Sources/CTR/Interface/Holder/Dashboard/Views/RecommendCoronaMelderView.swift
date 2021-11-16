/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RecommendCoronaMelderCardView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Spacing {
			static let messageToButton: CGFloat = 16
		}
	}
	
	let contentTextView = TextView()
	
	// MARK: - Lifecycle

	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = .white
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(contentTextView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		if let view = view {
			contentTextView.embed(in: view)
		}
	}
	
	/// The message
	var message: String? {
		didSet {
			contentTextView.attributedText = .makeFromHtml(
				text: message,
				style: NSAttributedString.HTMLStyle(
					font: Theme.fonts.body,
					textColor: Theme.colors.dark,
					paragraphSpacing: 0
				)
			)
		}
	}

	/// The user tapped on a link
	var urlTapHandler: ((URL) -> Void)? {
		didSet {
			contentTextView.linkTouched { [weak self] (url: URL) in
				self?.urlTapHandler?(url)
			}
		}
	}
}

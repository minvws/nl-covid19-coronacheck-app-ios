/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RecommendCoronaMelderCardView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Message {
			static let kerning: CGFloat = -0.24
		}
	}
	
	private let contentTextView = TextView()
	
	// MARK: - Lifecycle

	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(contentTextView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		if let view {
			contentTextView.embed(in: view)
		}
	}
	
	/// The message
	var message: String? {
		didSet {
			
			NSAttributedString.makeFromHtml(
				text: message,
				style: NSAttributedString.HTMLStyle(
					font: Fonts.subhead,
					textColor: C.grey1()!,
					kern: ViewTraits.Message.kerning,
					paragraphSpacing: 0
				)
			) {
				self.contentTextView.attributedText = $0
			}
		}
	}

	/// The user tapped on a link
	var urlTapHandler: ((URL) -> Void)? {
		didSet {
			contentTextView.linkTouchedHandler = { [weak self] (url: URL) in
				self?.urlTapHandler?(url)
			}
		}
	}
}

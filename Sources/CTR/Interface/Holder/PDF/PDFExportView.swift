/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import ReusableViews
import Resources

class PDFExportView: ScrolledStackView {
	
	/// The display constants
	private struct ViewTraits {
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
	}

	private let titleLabel: Label = {
		
		return Label(title3: nil, montserrat: true).multiline().header()
	}()
	
	let messageTextView: TextView = {
		
		return TextView()
	}()

	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
		let linkTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: C.primaryBlue() as Any]
		messageTextView.linkTextAttributes = linkTextAttributes
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageTextView)
	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(
				text: message,
				style: NSAttributedString.HTMLStyle(
					font: Fonts.body,
					textColor: C.black()!,
					paragraphSpacing: 0
				)
			) {
				self.messageTextView.attributedText = $0
			}
		}
	}
}

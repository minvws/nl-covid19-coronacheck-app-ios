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
		enum Card {
			static let cornerRadius: CGFloat = 10.0
			static let borderWidth: CGFloat = 1.0
		}
	}

	private let titleLabel: Label = {
		
		return Label(title3: nil, montserrat: true).multiline().header()
	}()
	
	let messageTextView: TextView = {
		
		return TextView()
	}()
	
	let cardView: PDFExportCardView = {
		
		let view = PDFExportCardView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = ViewTraits.Card.cornerRadius
		view.layer.borderWidth = ViewTraits.Card.borderWidth
		view.layer.borderColor = C.grey4()?.cgColor
		return view
	}()

	private let activityIndicatorView: ActivityIndicatorView = {
		
		let view = ActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override func setupViews() {
		
		super.setupViews()
		
		backgroundColor = C.white()
		
		let linkTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: C.primaryBlue() as Any]
		messageTextView.linkTextAttributes = linkTextAttributes
	}
	
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		
		addSubview(activityIndicatorView)
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageTextView)
		stackView.addArrangedSubview(cardView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
			activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
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
	
	var shouldShowLoadingSpinner: Bool = false {
		didSet {
			activityIndicatorView.shouldShowLoadingSpinner = shouldShowLoadingSpinner
		}
	}
}

/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DCCQRLabelMessageView: BaseView, DCCQRLabelViewable {
	
	/// The display constants
	private enum ViewTraits {
		static let spacing: CGFloat = 1
	}
	
	private let labelView: DCCQRLabelView = {
		let view = DCCQRLabelView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let messageTextView: TextView = {
		let textView = TextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		return textView
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(labelView)
		addSubview(messageTextView)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			labelView.topAnchor.constraint(equalTo: topAnchor),
			labelView.leadingAnchor.constraint(equalTo: leadingAnchor),
			labelView.trailingAnchor.constraint(equalTo: trailingAnchor),
			
			messageTextView.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: ViewTraits.spacing),
			messageTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
			messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
			messageTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Public Access
	
	/// The dcc field
	var field: String? {
		get {
			return labelView.field
		}
		set {
			labelView.field = newValue
		}
	}
	
	/// The dcc value
	var value: String? {
		get {
			return labelView.value
		}
		set {
			labelView.value = newValue
		}
	}
	
	/// Set up labels to support SwitchControl accessibility
	func updateAccessibilityStatus() {
		labelView.updateAccessibilityStatus()
	}
	
	var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(text: message, style: .init(font: Fonts.subhead, textColor: C.black()!)) { attributedString in
				self.messageTextView.attributedText = attributedString
			}
		}
	}
}

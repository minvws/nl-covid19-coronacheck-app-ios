/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DCCQRLabelMessageView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		static let spacing: CGFloat = 1
	}
	
	let labelView: DCCQRLabelView = {
		let view = DCCQRLabelView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let messageTextView: TextView = {
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
			labelView.leftAnchor.constraint(equalTo: leftAnchor),
			labelView.rightAnchor.constraint(equalTo: rightAnchor),
			
			messageTextView.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: ViewTraits.spacing),
			messageTextView.leftAnchor.constraint(equalTo: leftAnchor),
			messageTextView.rightAnchor.constraint(equalTo: rightAnchor),
			messageTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	var message: String? {
		didSet {
			messageTextView.attributedText = .makeFromHtml(text: message,
														   style: .init(font: Fonts.subhead, textColor: C.black()!))
		}
	}
}

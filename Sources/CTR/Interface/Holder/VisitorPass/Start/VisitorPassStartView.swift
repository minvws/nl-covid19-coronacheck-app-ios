/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class VisitorPassStartView: ScrolledStackWithButtonView {
	
	/// The display constants
	private struct ViewTraits {
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
	}
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	let contentTextView: TextView = {
		
		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = C.white()
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextView)
	}
	
	// MARK: Public Access
	
	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	/// The message
	var message: String? {
		didSet {
			contentTextView.applyHTML(message)
		}
	}
}

/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ErrorView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimension
		static let imageSize: CGFloat = 16.0
		
		// Margins
		static let margin: CGFloat = 20.0
		static let textLeadingMargin: CGFloat = 8.0
		static let imageTopMargin: CGFloat = 5.0
		
		enum Font {
			static let font: UIFont = Fonts.subhead
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}
	}
	
	/// The error image
	private let errorImageView: UIImageView = {
		
		let view = UIImageView(image: I.error())
		view.translatesAutoresizingMaskIntoConstraints = false
		view.tintColor = C.error()
		return view
	}()
	
	/// The title label
	private let errorLabel: Label = {
		
		return Label(subhead: nil).multiline()
	}()
	
	override func setupViews() {
		
		super.setupViews()
		view?.backgroundColor = .clear
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(errorImageView)
		addSubview(errorLabel)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		let iconOffset = ViewTraits.Font.lineHeight - ViewTraits.Font.font.ascender
		
		NSLayoutConstraint.activate([
			
			// Image View
			errorImageView.leadingAnchor.constraint( equalTo: leadingAnchor),
			errorImageView.widthAnchor.constraint(equalToConstant: ViewTraits.imageSize),
			errorImageView.heightAnchor.constraint(equalToConstant: ViewTraits.imageSize),
			errorImageView.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.imageTopMargin
			),
			
			// Title
			errorLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: iconOffset
			),
			errorLabel.leadingAnchor.constraint(
				equalTo: errorImageView.trailingAnchor,
				constant: ViewTraits.textLeadingMargin
			),
			errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Public Access
	
	/// The header
	var error: String? {
		didSet {
			errorLabel.attributedText = error?.setLineHeight(
				ViewTraits.Font.lineHeight,
				kerning: ViewTraits.Font.kerning,
				textColor: C.error()!
			)
			
			if let error = error {
				accessibilityValue = error
				accessibilityLabel = L.general_notification()
 				isAccessibilityElement = true
			} else {
				isAccessibilityElement = false
			}
		}
	}
}

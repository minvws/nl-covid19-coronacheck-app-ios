/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

open class ErrorView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		enum Image {
			static let size: CGFloat = 16.0
			static let topMargin: CGFloat = 5.0
		}
		enum Text {
			static let leadingMargin: CGFloat = 8.0
		}
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
		view.tintColor = C.ccError()
		return view
	}()
	
	/// The title label
	private let errorLabel: Label = {
		
		return Label(subhead: nil).multiline()
	}()
	
	override open func setupViews() {
		
		super.setupViews()
		view?.backgroundColor = .clear
	}
	
	/// Setup the hierarchy
	override open func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(errorImageView)
		addSubview(errorLabel)
	}
	
	/// Setup the constraints
	override open func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		let iconOffset = ViewTraits.Font.lineHeight - ViewTraits.Font.font.ascender
		
		NSLayoutConstraint.activate([
			
			// Image View
			errorImageView.leadingAnchor.constraint( equalTo: leadingAnchor),
			errorImageView.widthAnchor.constraint(equalToConstant: ViewTraits.Image.size),
			errorImageView.heightAnchor.constraint(equalToConstant: ViewTraits.Image.size),
			errorImageView.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.Image.topMargin
			),
			
			// Title
			errorLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: iconOffset
			),
			errorLabel.leadingAnchor.constraint(
				equalTo: errorImageView.trailingAnchor,
				constant: ViewTraits.Text.leadingMargin
			),
			errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Public Access
	
	/// The header
	public var error: String? {
		didSet {
			errorLabel.attributedText = error?.setLineHeight(
				ViewTraits.Font.lineHeight,
				kerning: ViewTraits.Font.kerning,
				textColor: C.ccError()!
			)
			
			if let error {
				accessibilityValue = error
				accessibilityLabel = L.general_notification()
 				isAccessibilityElement = true
			} else {
				isAccessibilityElement = false
			}
		}
	}
}

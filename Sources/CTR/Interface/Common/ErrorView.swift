/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ErrorView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimension
		static let imageSize: CGFloat = 12.0
		static let errorKerning: CGFloat = -0.24
		
		// Margins
		static let margin: CGFloat = 20.0
		static let messageTopMargin: CGFloat = 4.0
		static let fontOffset: CGFloat = 2.0
	}
	
	/// The error image
	private let errorImageView: UIImageView = {
		let view = UIImageView(image: .error)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.tintColor = Theme.colors.utilityError
		return view
	}()
	
	/// The title label
	private let errorLabel: Label = {
		
		return Label(subhead: nil).multiline()
	}()
	
	override func setupViews() {
		
		super.setupViews()
		view?.backgroundColor = .clear
		errorLabel.textColor = Theme.colors.utilityError
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
		
		NSLayoutConstraint.activate([
			
			// Header
			errorImageView.leadingAnchor.constraint( equalTo: leadingAnchor),
			errorImageView.widthAnchor.constraint(equalToConstant: ViewTraits.imageSize),
			errorImageView.heightAnchor.constraint(equalToConstant: ViewTraits.imageSize),
			errorImageView.centerYAnchor.constraint(
				equalTo: errorLabel.centerYAnchor,
				constant: ViewTraits.fontOffset
			),
			
			// Title
			errorLabel.topAnchor.constraint(equalTo: topAnchor),
			errorLabel.leadingAnchor.constraint(
				equalTo: errorImageView.trailingAnchor,
				constant: 5
			),
			errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Public Access
	
	/// The header
	var error: String? {
		didSet {
			errorLabel.attributedText = error?.setLineHeight(kerning: ViewTraits.errorKerning)
		}
	}
}

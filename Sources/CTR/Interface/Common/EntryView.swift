/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class EntryView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let headerHeight: CGFloat = 38.0
		static let inputHeight: CGFloat = 52.0
		static let lineHeight: CGFloat = 1.0
	}
	
	/// The header label
	private let headerLabel: Label = {
		
		return Label(caption1SemiBold: nil).multiline()
	}()
	
	let inputField: UITextField = {
		
		let field = UITextField()
		field.translatesAutoresizingMaskIntoConstraints = false
		field.returnKeyType = .send
		field.autocorrectionType = .no
		field.autocapitalizationType = .none
		field.clearButtonMode = .whileEditing
		field.font = UIFont.preferredFont(forTextStyle: .body)
		return field
	}()
	
	private let lineView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = C.grey1()
		return view
	}()
	
	/// Setup all the views
	override func setupViews() {
		
		super.setupViews()
		let tapGestureRecognizer = UITapGestureRecognizer(
			target: self,
			action: #selector(handleSingleTap)
		)
		self.addGestureRecognizer(tapGestureRecognizer)
	}

	override func setupAccessibility() {
		super.setupAccessibility()

		// Don't wish to read the header via VoiceOver - instead
		// the field will be given the header as it's Title.
		headerLabel.isAccessibilityElement = false
	}
	
	/// User tapped on the view
	/// - Parameter sender: the tapgesture
	@objc func handleSingleTap() {
		
		inputField.becomeFirstResponder()
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(headerLabel)
		addSubview(inputField)
		addSubview(lineView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			// Header
			headerLabel.topAnchor.constraint(equalTo: topAnchor),
			headerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.headerHeight),
			headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			headerLabel.bottomAnchor.constraint(equalTo: inputField.topAnchor),
			
			// Input field
			inputField.leadingAnchor.constraint(equalTo: leadingAnchor),
			inputField.trailingAnchor.constraint(equalTo: trailingAnchor),
			inputField.bottomAnchor.constraint(equalTo: lineView.topAnchor),
			inputField.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.inputHeight),
			
			// Line
			lineView.heightAnchor.constraint(equalToConstant: ViewTraits.lineHeight),
			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	// MARK: Public Access
	
	/// The header
	var header: String? {
		didSet {
			headerLabel.text = header

			// For voiceover, the field should have the header as it's label: 
			inputField.accessibilityLabel = header
		}
	}
}

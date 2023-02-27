/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import Resources

/*
 Styled subclass of UITextView that can handle (simple) html.
 Auto expands to fit its content.
 By default the content is not editable or selectable.
 Can listen to selected links and updated text.
 */
open class TextElement: UITextView, UITextViewDelegate {
	
	/// Add a listener for selected links.
	///
	/// - parameter handler: The closure to be called when the user selects a link
	open var linkTouchedHandler: ((URL) -> Void)?
	
	/// Add a listener for updated text. Calling this method will set `isEditable` to `true`
	///
	/// - parameter handler: The closure to be called when the text is updated
	open var textChangedHandler: ((String?) -> Void)? {
		didSet {
			isEditable = textChangedHandler != nil
		}
	}
	
	///  Initializes the TextView with the given attributed string
	public init(attributedText: NSAttributedString) {
		super.init(frame: .zero, textContainer: nil)
		setup()
		
		self.attributedText = attributedText
		
		// Improve accessibility by trimming whitespace and newline characters
		if let mutableAttributedTextForAccessibility = attributedText.mutableCopy() as? NSMutableAttributedString {
			mutableAttributedTextForAccessibility.stripParagraphStyle()
			mutableAttributedTextForAccessibility.trim()
			accessibilityAttributedValue = mutableAttributedTextForAccessibility
		}
		
		setupAttributedStringLinks()
	}
	
	///  Initializes the TextView with the given string
	public init(text: String? = nil) {
		super.init(frame: .zero, textContainer: nil)
		setup()
		
		self.text = text
	}
	
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Sets up the TextElement with the default settings
	private func setup() {
		isAccessibilityElement = true
		delegate = self
		
		font = Fonts.body
		isScrollEnabled = false
		isEditable = false
		isSelectable = true // Default all textviews are selectable.
		backgroundColor = nil
		layer.cornerRadius = 0
		textContainer.lineFragmentPadding = 0
		textContainerInset = .zero
		linkTextAttributes = [
			.foregroundColor: C.primaryBlue()!,
			.underlineColor: C.primaryBlue()!
		]
	}
	
	private func setupAttributedStringLinks() {
		
		if let linkNSRange = attributedText.rangeOfFirstLink {
			
			// Work out the title of the linked text:
			let linkTitle = attributedText.attributedSubstring(from: linkNSRange).string
			
			if #available(iOS 13.0, *) {
				// Label the paragraph with the link title (VoiceControl), whilst
				// preventing _audibly_ labelling the whole paragraph with the link title (VoiceOver).
				accessibilityUserInputLabels = [linkTitle]
			} else {
				// Non-ideal fallback for <iOS 13: label the paragraph using the link name, so that
				// the user can tap it using Voice Control. (i.e. also reads it out using Voice Over too).
				accessibilityLabel = linkTitle
			}
			
			accessibilityTraits = .link
		} else {
			self.accessibilityTraits = .staticText
		}
	}
	
	/// Calculates the intrisic content size
	override open var intrinsicContentSize: CGSize {
		let superSize = super.intrinsicContentSize
		
		if isEditable {
			return CGSize(width: 200, height: max(114, superSize.height))
		} else {
			return superSize
		}
	}
	
	/// Delegate method to determine whether a URL can be interacted with
	open func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		switch interaction {
			case .invokeDefaultAction:
				guard let linkTouchedHandler = linkTouchedHandler else { return false }
				linkTouchedHandler(url)
			default:
				break
		}
		return false
	}
	
	/// Delegate method which is called when the user has ended editing
	open func textViewDidEndEditing(_ textView: UITextView) {
		textChangedHandler?(textView.text)
	}
}

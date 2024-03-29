/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Resources

/*
 Styled subclass of UIStackView that displays one or more TextElement's, which can handle (simple) html
 Auto expands to fit its content.
 By default the content is not editable or selectable.
 Can listen to selected links and updated text.
 */
open class TextView: UIStackView {
	
	var paragraphMarginMultiplier: CGFloat = 1.0
	var headerMarginMultiplier: CGFloat = 0.25
	var listItemMarginMultiplier: CGFloat = 0.25
	
	/// Helper variable to display the given text by using a TextElement
	public var text: String? {
		didSet {
			removeAllArrangedSubviews()
			
			let element = TextElement(text: text)
			addArrangedSubview(element)
		}
	}
	
	/// Helper variable to display a TextElement for each paragraph in the attributed string
	public var attributedText: NSAttributedString? {
		didSet {
			removeAllArrangedSubviews()
			
			guard let attributedText = attributedText else { return }
			
			// Split attributed text on new line
			let parts = attributedText.split("\n")
			
			for part in parts {
				// 1. Determine spacing of previous element
				if let previousElement = arrangedSubviews.last {
					var spacing = part.lineHeight
					
					if part.isHeader {
						spacing *= headerMarginMultiplier
					} else if part.isListItem {
						spacing *= listItemMarginMultiplier
					} else {
						spacing *= paragraphMarginMultiplier
					}
					
					setCustomSpacing(spacing, after: previousElement)
				}
				
				// 2. Add current TextElement
				let element = TextElement(attributedText: part)
				element.adjustsFontForContentSizeCategory = true
				
				// Mark as header?
				if part.isHeader {
					element.accessibilityTraits = .header
				}
				
				// Hide for assistive technologies?
				if part.isBlank {
					element.isAccessibilityElement = false
				}
				
				addArrangedSubview(element)
			}
			
			// Re-apply the `didSet` effect for the following
			// (because `textElements` are nil until this callback):
			self.applyLinkTouchedHandlerToTextElements()
			self.applyTextChangedHandlerToTextElements()
			self.applyLinkTextAttributesToTextElements()
		}
	}
	
	/// Helper variable to retrieve all subviews
	public var textElements: [TextElement] {
		return arrangedSubviews.compactMap { view in
			return view as? TextElement
		}
	}
	
	/// Helper variable to pass linkTextAttributes to each subview
	public var linkTextAttributes: [NSAttributedString.Key: Any]? = [.foregroundColor: C.primaryBlue() as Any ] {
		didSet {
			applyLinkTextAttributesToTextElements()
		}
	}
	
	public var linkTouchedHandler: ((URL) -> Void)? {
		didSet {
			applyLinkTouchedHandlerToTextElements()
		}
	}
	
	public var textChangedHandler: ((String?) -> Void)? {
		didSet {
			applyTextChangedHandlerToTextElements()
		}
	}
	
	/// Initializes the TextView by parsing the given string to HTML
	public init(htmlText: String) {
		
		super.init(frame: .zero)
		setup()
		applyHTML(htmlText)
	}
	
	//// Initializes the TextView with a string
	public init(text: String? = nil) {
		super.init(frame: .zero)
		setup()
		
		self.text = text
	}
	
	required public init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Set vertical alignment
	private func setup() {
		axis = .vertical
		translatesAutoresizingMaskIntoConstraints = false
	}
	
	/// Sets the content to the supplied html string.
	///
	public func applyHTML(_ htmlText: String?, completion: (() -> Void)? = nil) {
		NSAttributedString.makeFromHtml(text: htmlText, style: .bodyDark) { attributedString in
			self.attributedText = attributedString
			
			// Re-apply the `didSet` effect for the following
			// (because `textElements` are nil until this callback):
			self.applyLinkTouchedHandlerToTextElements()
			self.applyTextChangedHandlerToTextElements()
			self.applyLinkTextAttributesToTextElements()
			
			completion?()
		}
	}
	
	/// Removes all arranged subviews
	@discardableResult
	func removeAllArrangedSubviews() -> [UIView] {
		let removedSubviews = arrangedSubviews.reduce([]) { removedSubviews, subview -> [UIView] in
			self.removeArrangedSubview(subview)
			NSLayoutConstraint.deactivate(subview.constraints)
			subview.removeFromSuperview()
			return removedSubviews + [subview]
		}
		return removedSubviews
	}
	
	// MARK: - private functions
	
	private func applyLinkTouchedHandlerToTextElements() {
		textElements.forEach { $0.linkTouchedHandler = linkTouchedHandler }
	}
	
	private func applyTextChangedHandlerToTextElements() {
		textElements.forEach { $0.textChangedHandler = textChangedHandler }
	}
	
	private func applyLinkTextAttributesToTextElements() {
		textElements.forEach { $0.linkTextAttributes = linkTextAttributes }
	}
}

extension NSAttributedString {
	
	/// Helper method to split an attributed string by using the given separator
	func split(_ separator: String) -> [NSAttributedString] {
		var substrings = [NSAttributedString]()
		
		var index = 0
		for component in self.string.components(separatedBy: separator) {
			let range = NSRange(location: index, length: component.utf16.count)
			
			let substring = self.attributedSubstring(from: range)
			substrings.append(substring)
			
			index += range.length + separator.count
		}
		
		return substrings
	}
	
	/// Helper method to find certain attributes of an attributed string
	func attributes(find: (_ key: Key, _ value: Any, _ range: NSRange) -> (Bool)) -> Bool {
		var result = false
		enumerateAttributes(in: NSRange(location: 0, length: self.length)) { attributes, range, stop in
			for (key, value) in attributes where find(key, value, range) {
				result = true
				break
			}
		}
		return result
	}
	
	/// Determines whether the attributed string is a header
	var isHeader: Bool {
		return attributes { key, value, range in
			// Check if header level is h1 or higher
			if key == NSAttributedString.Key.paragraphStyle,
			   let paragraphStyle = value as? NSParagraphStyle,
			   paragraphStyle.headerLevel >= 1 {
				return true
			}
			
			// Check if full range uses a bold font
			if key == NSAttributedString.Key.font,
			   let font = value as? UIFont,
			   font.fontDescriptor.symbolicTraits.contains(.traitBold),
			   range.lowerBound == 0,
			   range.upperBound >= self.length - 1 {
				return true
			}
			
			return false
		}
	}
	
	/// Determines whether the attributed string contains a link
	var rangeOfFirstLink: NSRange? {
		var foundRange: NSRange?
		
		_ = attributes { key, value, range in
			guard key == NSAttributedString.Key.link else { return false }
			foundRange = range
			return true
		}
		
		return foundRange
	}
	
	// swiftlint:disable empty_count
	/// Determines whether the attributed string is a list item
	var isListItem: Bool {
		// Check if strings starts with tabbed bullet character
		if string.starts(with: "\t●") || string.starts(with: "\t•") {
			return true
		}
		
		// Check if textLists attribute contains one or more elements
		return attributes { key, value, _ in
			
			if key == NSAttributedString.Key.paragraphStyle,
			   let paragraphStyle = value as? NSParagraphStyle,
			   paragraphStyle.textLists.count > 0 {
				return true
			}
			return false
		}
	}
	// swiftlint:enable empty_count
	
	/// Determines the line height used for the attributed string
	var lineHeight: CGFloat {
		var height: CGFloat = 0
		
		// Retrieve the maximum value set for minimumLineHeight in NSParagraphStyle
		enumerateAttributes(in: NSRange(location: 0, length: self.length)) { attributes, range, stop in
			for (key, value) in attributes {
				if key == NSAttributedString.Key.paragraphStyle,
				   let paragraphStyle = value as? NSParagraphStyle,
				   paragraphStyle.minimumLineHeight > height {
					height = paragraphStyle.minimumLineHeight
				}
			}
		}
		
		return height
	}
	
	/// Determines if the attributed string is blank
	var isBlank: Bool {
		return string.trimmingCharacters(in: .whitespaces).isEmpty
	}
}

extension NSParagraphStyle {
	
	var headerLevel: Int {
		let key = "headerLevel"
		if responds(to: NSSelectorFromString(key)) {
			return value(forKey: key) as? Int ?? 0
		}
		return 0
	}
	
	var textLists: NSArray {
		let key = "textLists"
		if responds(to: NSSelectorFromString(key)) {
			return value(forKey: key) as? NSArray ?? []
		}
		return []
	}
}

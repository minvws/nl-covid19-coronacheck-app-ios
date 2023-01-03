/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension String {
	func components(separatedBy separators: [some StringProtocol]) -> [String] {
		var result = [self]
		for separator in separators {
			result = result
				.map { $0.components(separatedBy: separator) }
				.flatMap { $0 }
				.filter { !$0.isEmpty }
		}
		return result
	}
}

public extension NSAttributedString {

	struct HTMLStyle {
		let font: UIFont
		let textColor: UIColor
		let lineHeight: CGFloat
		let kern: CGFloat
		let paragraphSpacing: CGFloat

		init(font: UIFont, textColor: UIColor, lineHeight: CGFloat = 22, kern: CGFloat = -0.41, paragraphSpacing: CGFloat = 8) {
			self.font = font
			self.textColor = textColor
			self.lineHeight = lineHeight
			self.kern = kern
			self.paragraphSpacing = paragraphSpacing
		}

		static var bodyDark: HTMLStyle = HTMLStyle(font: Fonts.body, textColor: C.black()!)
	}
}

public extension NSAttributedString {

	static func makeFromHtml(text: String?, style: HTMLStyle, completion: @escaping (NSAttributedString) -> Void) {

		guard !ProcessInfo.processInfo.isUnitTesting else {
			completion(NSAttributedString(string: text ?? ""))
			return
		}

		DispatchQueue.main.async {
			let result = makeFromHtml(text: text, style: style)
			completion(result)
		}
	}
	
	static func makeFromHtml(text: String?, style: HTMLStyle) -> NSAttributedString {

		guard !ProcessInfo.processInfo.isUnitTesting else {
			return NSAttributedString(string: text ?? "")
		}

		let text = text ?? ""
		let result = NSMutableAttributedString()

		let segments = splitIntoSegments(text)
		segments
			.map { convertSegment($0, style: style) }
			.forEach { result.append($0) }

		removeTrailingNewlines(in: result)

		return result
	}

	private static func splitIntoSegments(_ text: String) -> [String] {

		// Split text for any list tags, so they can be styled separately and properly
		func wrapInListIfNeeded(_ segment: String) -> String {
			if segment.contains("<li>") {
				return "<br/><ul>" + segment + "</ul>"
			} else {
				return segment
			}
		}

		let components = text
			.components(separatedBy: ["<ul>", "</ul>"])
			.map(wrapInListIfNeeded)

		return components
	}

	private static func convertSegment(_ segment: String, style: HTMLStyle) -> NSAttributedString {

		let attributes = createAttributes(style: style)
		let data: Data = segment.data(using: .unicode) ?? Data(segment.utf8)

		guard let attributedText = try? NSMutableAttributedString(
				data: data,
				options: [.documentType: NSAttributedString.DocumentType.html],
				documentAttributes: nil) else {
			return NSAttributedString(string: segment)
		}

		let fullRange = NSRange(location: 0, length: attributedText.length)
		attributedText.addAttributes(attributes, range: fullRange)

		replaceFonts(in: attributedText, style: style)
		replaceBullets(in: attributedText, style: style)
		replaceListParagraphStyle(in: attributedText, style: style)

		return attributedText
	}

	private static func createAttributes(style: HTMLStyle) -> [Key: Any] {

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .natural
		paragraphStyle.paragraphSpacing = style.paragraphSpacing
		paragraphStyle.minimumLineHeightAdjustedForContentSize(style.lineHeight)

		let attributes: [Key: Any] = [
			.foregroundColor: style.textColor,
			.paragraphStyle: paragraphStyle,
			.kern: style.kern
		]

		return attributes
	}

	private static func createListParagraphStyle(style: HTMLStyle) -> NSParagraphStyle {

		let tabInterval: CGFloat = 20
		var tabStops = [NSTextTab]()
		tabStops.append(NSTextTab(textAlignment: .natural, location: 1))
		for index in 1...12 {
			tabStops.append(NSTextTab(textAlignment: .natural, location: CGFloat(index) * tabInterval))
		}

		let listParagraphStyle = NSMutableParagraphStyle()
		listParagraphStyle.alignment = .natural
		listParagraphStyle.paragraphSpacing = 8
		listParagraphStyle.tabStops = tabStops
		listParagraphStyle.headIndent = tabInterval
		listParagraphStyle.firstLineHeadIndent = 0
		listParagraphStyle.minimumLineHeightAdjustedForContentSize(style.lineHeight)

		return listParagraphStyle
	}

	static func replaceFonts(in text: NSMutableAttributedString, style: HTMLStyle) {

		let fullRange = NSRange(location: 0, length: text.length)

		let boldFontDescriptor = style.font.fontDescriptor.withSymbolicTraits(.traitBold)
		let boldFont = boldFontDescriptor.map { UIFont(descriptor: $0, size: style.font.pointSize) }

		text.enumerateAttribute(.font, in: fullRange, options: []) { value, range, finished in
			guard let currentFont = value as? UIFont else { return }

			let newFont: UIFont

			if let boldFont, currentFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
				newFont = boldFont
			} else {
				newFont = style.font
			}

			text.removeAttribute(.font, range: range)
			text.removeAttribute(.foregroundColor, range: range)

			text.addAttribute(.font, value: newFont, range: range)
			text.addAttribute(.foregroundColor, value: style.textColor, range: range)
		}
	}

	private static let listBulletCharacter = "\u{25CF}"

	private static func replaceBullets(in text: NSMutableAttributedString, style: HTMLStyle) {

		let bulletFont = style.font.withSize(5)
		let bulletAttributes: [NSAttributedString.Key: Any] = [
			.font: bulletFont,
			.foregroundColor: C.black()!,
			.baselineOffset: (style.font.xHeight - bulletFont.xHeight) / 2
		]

		let currentText = text.string
		var searchRange = NSRange(location: 0, length: currentText.count)
		var foundRange = NSRange()
		while searchRange.location < currentText.count {
			searchRange.length = currentText.count - searchRange.location
			foundRange = (currentText as NSString).range(of: "•", options: [], range: searchRange)
			if foundRange.location != NSNotFound {
				searchRange.location = foundRange.location + foundRange.length
				text.replaceCharacters(in: foundRange, with: NSAttributedString(string: listBulletCharacter, attributes: bulletAttributes))
			} else {
				break
			}
		}
	}

	private static func replaceListParagraphStyle(in text: NSMutableAttributedString, style: HTMLStyle) {

		let fullRange = NSRange(location: 0, length: text.length)
		let listParagraphStyle = createListParagraphStyle(style: style)

		var previousParagraphIsListStart = false
		text.enumerateAttribute(.paragraphStyle, in: fullRange, options: []) { value, range, finished in

			let searchText = text.string as NSString
			if searchText.substring(with: range).starts(with: listBulletCharacter) {
				var startRange = range
				if range.location > 0 {
					// adjust the range so the style is set before the line starts so indentations are properly calculated
					startRange.location -= 1
					startRange.length += 1
				}
				text.removeAttribute(.paragraphStyle, range: startRange)
				text.addAttribute(.paragraphStyle, value: listParagraphStyle, range: startRange)
				previousParagraphIsListStart = true
			} else if previousParagraphIsListStart {
				text.removeAttribute(.paragraphStyle, range: range)
				text.addAttribute(.paragraphStyle, value: listParagraphStyle, range: range)
				previousParagraphIsListStart = false
			}
		}
	}

	private static func removeTrailingNewlines(in text: NSMutableAttributedString) {
		
		while text.string.hasSuffix("\n") {
			let range = NSRange(location: text.string.count - 1, length: 1)
			text.replaceCharacters(in: range, with: "")
		}
	}
}

extension NSMutableParagraphStyle {
	
	func minimumLineHeightAdjustedForContentSize(_ lineHeight: CGFloat) {
		minimumLineHeight = lineHeight * UIContentSizeCategory.currentSizeMultiplier
	}
}

public extension NSMutableAttributedString {
	
	/// Trims white space and new line at the start and end
	func trim() {
		let characterSet = CharacterSet.whitespacesAndNewlines.inverted
		
		// Trim start:
		let startRange = string.rangeOfCharacter(from: characterSet)
		guard let startLocation = startRange?.lowerBound else { return }
		
		let frontTrimRange = NSRange(string.startIndex..<startLocation, in: string)
		replaceCharacters(in: frontTrimRange, with: "")
		
		// Trim end:
		let endRange = string.rangeOfCharacter(from: characterSet, options: .backwards)
		guard let endLocation = endRange?.upperBound else { return }
		
		let endTrimRange = NSRange(endLocation ..< string.endIndex, in: string)
		replaceCharacters(in: endTrimRange, with: "")
	}
	
	/// Strip bullets (<li>) so that they're not read out loud
	func stripParagraphStyle() {
		
		removeAttribute(.paragraphStyle, range: NSRange(location: 0, length: length))
	}
}

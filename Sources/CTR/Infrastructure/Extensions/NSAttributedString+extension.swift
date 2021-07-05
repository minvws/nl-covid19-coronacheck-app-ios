/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension NSAttributedString {

	/// Set the line height
	/// - Parameter lineHeight: the line height
	/// - Returns: attributed string
	func setLineHeight(_ lineHeight: CGFloat = 20.0, alignment: NSTextAlignment = .left, kerning: CGFloat = 0.0) -> NSAttributedString {

		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineBreakMode = .byWordWrapping
		paragraphStyle.alignment = alignment
		paragraphStyle.minimumLineHeight = lineHeight

		let attrString = NSMutableAttributedString(attributedString: self)
		attrString.addAttributes(
			[
				.paragraphStyle: paragraphStyle,
				.kern: kerning
			],
			range: _NSRange(
				location: 0,
				length: self.length
			)
		)
		return attrString
	}

	/// bold a part of the text
	/// - Parameters:
	///   - bold: the part to bold
	///   - color: the color to bold with
	/// - Returns: attributed string
	func bold(_ bolds: [String], with font: UIFont) -> NSAttributedString {

		let output = NSMutableAttributedString(attributedString: self)

		for bold in bolds {

			if let boldRange = self.string.range(of: bold) {
				let attributes: [NSAttributedString.Key: Any] = [
					.font: font
				]

				output.addAttributes(attributes, range: NSRange(boldRange, in: self.string))
			}
		}

		return output
	}

	func rangeOf(string: String) -> Range<String.Index>? {
		
		return self.string.range(of: string)
	}
}

public extension NSAttributedString {

	static func makeFromHtml(
		text: String?,
		font: UIFont,
		textColor: UIColor,
		boldTextColor: UIColor? = nil,
		textAlignment: NSTextAlignment = .left,
		lineHeight: CGFloat = 22,
		underlineColor: UIColor? = nil,
		kern: CGFloat = -0.41,
		paragraphSpacing: CGFloat = 8) -> NSAttributedString {

		guard !ProcessInfo.processInfo.isTesting else {

			return NSAttributedString(string: text ?? "")
		}

		let text = text ?? ""
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = textAlignment
		paragraphStyle.paragraphSpacing = paragraphSpacing
		paragraphStyle.minimumLineHeight = lineHeight

		let listParagraphStyle = NSMutableParagraphStyle()

		// create custom tabstops to align lists
		let tabInterval: CGFloat = 20
		var tabStops = [NSTextTab]()
		tabStops.append(NSTextTab(textAlignment: .natural, location: 1))
		for index in 1...12 {
			tabStops.append(NSTextTab(textAlignment: .natural, location: CGFloat(index) * tabInterval))
		}

		listParagraphStyle.alignment = textAlignment
		listParagraphStyle.paragraphSpacing = 8
		listParagraphStyle.tabStops = tabStops
		listParagraphStyle.headIndent = tabInterval
		listParagraphStyle.firstLineHeadIndent = 0

		var attributes: [Key: Any] = [
			.foregroundColor: textColor,
			.paragraphStyle: paragraphStyle,
			.kern: kern
		]
		if let underlineColor = underlineColor {
			attributes[.underlineColor] = underlineColor
			attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
		}
		let data: Data = text.data(using: .unicode) ?? Data(text.utf8)

		if let attributedTitle = try? NSMutableAttributedString(
			data: data,
			options: [.documentType: NSAttributedString.DocumentType.html],
			documentAttributes: nil) {

			let fullRange = NSRange(location: 0, length: attributedTitle.length)
			attributedTitle.addAttributes(attributes, range: fullRange)

			let boldFontDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)
			let boldFont = boldFontDescriptor.map { UIFont(descriptor: $0, size: font.pointSize) }

			// replace default font with desired font - maintain bold style if possible
			attributedTitle.enumerateAttribute(.font, in: fullRange, options: []) { value, range, finished in
				guard let currentFont = value as? UIFont else { return }

				let newFont: UIFont
				let newColor: UIColor

				if let boldFont = boldFont, currentFont.fontDescriptor.symbolicTraits.contains(.traitBold) {
					newFont = boldFont
					newColor = boldTextColor ?? textColor
				} else {
					newFont = font
					newColor = textColor
				}

				attributedTitle.removeAttribute(.font, range: range)
				attributedTitle.removeAttribute(.foregroundColor, range: range)

				attributedTitle.addAttribute(.font, value: newFont, range: range)
				attributedTitle.addAttribute(.foregroundColor, value: newColor, range: range)
			}

			// Replace added bullets with styled bullets
			let bulletFont = font.withSize(10)
			let bulletAttributes: [NSAttributedString.Key: Any] = [
				.font: bulletFont,
				.foregroundColor: Theme.colors.dark,
				.baselineOffset: (font.xHeight - bulletFont.xHeight) / 2
			]
			let listBulletCharacter = "\u{25CF}"
			let currentText = attributedTitle.string
			var searchRange = NSRange(location: 0, length: currentText.count)
			var foundRange = NSRange()
			while searchRange.location < currentText.count {
				searchRange.length = currentText.count - searchRange.location
				foundRange = (currentText as NSString).range(of: "•", options: [], range: searchRange)
				if foundRange.location != NSNotFound {
					searchRange.location = foundRange.location + foundRange.length
					attributedTitle.replaceCharacters(
						in: foundRange,
						with: NSAttributedString(
							string: listBulletCharacter,
							attributes: bulletAttributes
						)
					)
				} else {
					break
				}
			}

			// Replace list paragraph style
			var previousParagraphIsListStart = false
			attributedTitle.enumerateAttribute(.paragraphStyle, in: fullRange, options: []) { value, range, finished in

				let text = attributedTitle.string as NSString
				if text.substring(with: range).starts(with: listBulletCharacter) {
					var startRange = range
					if range.location > 0 {
						// adjust the range so the style is set before the line starts so indentations are properly calculated
						startRange.location -= 1
						startRange.length += 1
					}
					attributedTitle.removeAttribute(.paragraphStyle, range: startRange)
					attributedTitle.addAttribute(.paragraphStyle, value: listParagraphStyle, range: startRange)
					previousParagraphIsListStart = true
				} else if previousParagraphIsListStart {
					previousParagraphIsListStart = false
				}
			}

			// remove any trailing newlines
			while attributedTitle.string.hasSuffix("\n") {
				let range = NSRange(location: attributedTitle.string.count - 1, length: 1)
				attributedTitle.replaceCharacters(in: range, with: "")
			}

			return attributedTitle
		}

		return NSAttributedString(string: text)
	}
}

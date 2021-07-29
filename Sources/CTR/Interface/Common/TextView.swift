/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

/// Styled subclass of UIStackView that can handle (simple) html.
/// Auto expands to fit its content.
/// By default the content is not editable or selectable.
/// Can listen to selected links and updated text.
class TextView: UIStackView {
    
    var text: String? {
        didSet {
            print("Did set text")
        }
    }
    
    var attributedText: NSAttributedString? {
        didSet {
            print("Did set attributedText")
            
            guard let attributedText = attributedText else { return }
            
            let parts = attributedText.split("\n")
            for part in parts {
                print("\n\nPart: \(part)\n\n")
                
                let element = TextElement(attributedText: part)
                
                if part.isHeader {
                    element.accessibilityTraits = .header
                }
                
                addArrangedSubview(element)
            }
        }
    }
    
    var linkTextAttributes: [NSAttributedString.Key : Any]? {
        didSet {
            print("Did set linkTextAttributes")
        }
    }
    
    private var linkHandlers = [(URL) -> Void]() {
        didSet {
            print("Did set linkHandlers")
        }
    }
    
    private var textChangedHandlers = [(String?) -> Void]() {
        didSet {
            print("Did set textChangedHandlers")
        }
    }
    
    init(
		htmlText: String,
		font: UIFont = Theme.fonts.body,
		textColor: UIColor = Theme.colors.dark,
		boldTextColor: UIColor = Theme.colors.dark) {
        super.init(frame: .zero)
        setup()
        
        html(htmlText, font: font, textColor: textColor, boldTextColor: boldTextColor)
    }
    
    init(text: String? = nil) {
        super.init(frame: .zero)
        setup()
        
        self.text = text
    }
    
    init(attributedText: NSAttributedString) {
        super.init(frame: .zero)
        setup()
        
        self.attributedText = attributedText
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        axis = .vertical
    }
        
    /// Sets the content to the supplied html string.
    @discardableResult
	func html(_ htmlText: String?, font: UIFont = Theme.fonts.body, textColor: UIColor = Theme.colors.dark, boldTextColor: UIColor = Theme.colors.dark) -> Self {
        attributedText = .makeFromHtml(text: htmlText, font: font, textColor: textColor, boldTextColor: boldTextColor)
        return self
    }
    
    /// Add a listener for selected links. Calling this method will set `isSelectable` to `true`
    ///
    /// - parameter handler: The closure to be called when the user selects a link
    @discardableResult
    func linkTouched(handler: @escaping (URL) -> Void) -> Self {
        linkHandlers.append(handler)
        return self
    }
    
    /// Add a listener for updated text. Calling this method will set `isSelectable` and `isEditable` to `true`
    ///
    /// - parameter handler: The closure to be called when the text is updated
    @discardableResult
    func textChanged(handler: @escaping (String?) -> Void) -> Self {
        textChangedHandlers.append(handler)
        return self
    }
}

extension NSAttributedString {
    
    func split(_ separator: String) -> [NSAttributedString] {
        var substrings = [NSAttributedString]()
        
        var index = 0
        for component in self.string.components(separatedBy: separator) {
            let range = NSMakeRange(index, component.utf16.count)
            
            let substring = self.attributedSubstring(from: range)
            substrings.append(substring)
            
            index += range.length + separator.count
        }
        
        return substrings
    }
    
    func attributes(find: (_ key: Key, _ value: Any, _ range: NSRange) -> (Bool)) -> Bool {
        var result = false
        enumerateAttributes(in: NSRange(location: 0, length: self.length)) { (attributes, range, stop) in
            for (key, value) in attributes {
                if find(key, value, range) {
                    result = true
                    break
                }
            }
        }
        return result
    }
    
    var isHeader: Bool {
        get {
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
    }
    
    // swiftlint:disable all [empty_count]
    var isListItem: Bool {
        get {
            return attributes { key, value, _ in
                // Check if textLists attribute is not empty
                if key == NSAttributedString.Key.paragraphStyle,
                   let paragraphStyle = value as? NSParagraphStyle,
                   paragraphStyle.textLists.count > 0 {
                    return true
                }
                return false
            }
        }
    }
}

extension NSParagraphStyle {
    
    var headerLevel: Int {
        get {
            let key = "headerLevel"
            if responds(to: NSSelectorFromString(key)) {
                return value(forKey: key) as? Int ?? 0
            }
            return 0
        }
    }
    
    var textLists: NSArray {
        let key = "textLists"
        if responds(to: NSSelectorFromString(key)) {
            return value(forKey: key) as? NSArray ?? []
        }
        return []
    }
}

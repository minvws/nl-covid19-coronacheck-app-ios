/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

/// Styled subclass of UITextView that can handle (simple) html.
/// Auto expands to fit its content.
/// By default the content is not editable or selectable.
/// Can listen to selected links and updated text.
class TextElement: UITextView, UITextViewDelegate {
    
    private var linkHandlers = [(URL) -> Void]()
    private var textChangedHandlers = [(String?) -> Void]()
    
    ///  Initializes the TextView with the given attributed string
    init(
        attributedText: NSAttributedString,
        font: UIFont = Theme.fonts.body,
        textColor: UIColor = Theme.colors.dark,
        boldTextColor: UIColor = Theme.colors.dark
    ) {
        super.init(frame: .zero, textContainer: nil)
        setup()
        
        self.attributedText = attributedText
        
        // Improve accessibility by trimming whitespace and newline characters
        if let mutableAttributedText = attributedText.mutableCopy() as? NSMutableAttributedString {
            accessibilityAttributedValue = mutableAttributedText.trim()
        }
		
		let containsLink = attributedText.containsLink
		self.accessibilityLabel = containsLink ? L.generalUrlLink() : nil
		self.accessibilityValue = containsLink ? attributedText.string : nil
		self.accessibilityTraits = containsLink ? .link : .staticText
		self.isAccessibilityElement = containsLink
    }
    
    ///  Initializes the TextView with the given string
    init(text: String? = nil) {
        super.init(frame: .zero, textContainer: nil)
        setup()
        
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Sets up the TextElement with the default settings
    private func setup() {
        isAccessibilityElement = true
        delegate = self
        
        font = Theme.fonts.body
        isScrollEnabled = false
        isEditable = false
        isSelectable = false
        backgroundColor = nil
        layer.cornerRadius = 0
        textContainer.lineFragmentPadding = 0
        textContainerInset = .zero
        linkTextAttributes = [
            .foregroundColor: Theme.colors.iosBlue,
            .underlineColor: Theme.colors.iosBlue
        ]
    }
    
    /// Calculates the intrisic content size
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        
        if isEditable {
            return CGSize(width: 200, height: max(114, superSize.height))
        } else {
            return superSize
        }
    }
    
    /// Add a listener for selected links. Calling this method will set `isSelectable` to `true`
    ///
    /// - parameter handler: The closure to be called when the user selects a link
    @discardableResult
	func linkTouched(handler: @escaping (URL) -> Void) -> Self {
        isSelectable = true
        linkHandlers.append(handler)
        return self
    }
    
    /// Add a listener for updated text. Calling this method will set `isSelectable` and `isEditable` to `true`
    ///
    /// - parameter handler: The closure to be called when the text is updated
    @discardableResult
    func textChanged(handler: @escaping (String?) -> Void) -> Self {
        isSelectable = true
        isEditable = true
        textChangedHandlers.append(handler)
        return self
    }
    
    /// Delegate method to determine whether a URL can be interacted with
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        switch interaction {
            case .invokeDefaultAction:
                linkHandlers.forEach { $0(URL) }
            default:
                return false
        }
        
        return false
    }
    
    /// Delegate method which is called when the user has ended editing
    func textViewDidEndEditing(_ textView: UITextView) {
        textChangedHandlers.forEach { $0(textView.text) }
    }
    
    /// Delegate method which is called when the user has changed selection
    func textViewDidChangeSelection(_ textView: UITextView) {
        // Allows links to be tapped but disables text selection
        textView.selectedTextRange = nil
    }
}

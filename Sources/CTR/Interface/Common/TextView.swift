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
///
/// # See also:
/// [linkTouched(handler:)](x-source-tag://TextView.linkTouched),
/// [textChanged(handler:)](x-source-tag://TextView.textChanged)
class TextView: UITextView, UITextViewDelegate {
    
    private var linkHandlers = [(URL) -> Void]()
    private var textChangedHandlers = [(String?) -> Void]()
    
    init(
		htmlText: String,
		font: UIFont = Theme.fonts.body,
		textColor: UIColor = Theme.colors.dark,
		boldTextColor: UIColor = Theme.colors.dark) {
        super.init(frame: .zero, textContainer: nil)
        setup()
        
        html(htmlText, font: font, textColor: textColor, boldTextColor: boldTextColor)
    }
    
    init(text: String? = nil) {
        super.init(frame: .zero, textContainer: nil)
        setup()
        
        self.text = text
    }
    
    init(attributedText: NSAttributedString) {
        super.init(frame: .zero, textContainer: nil)
        setup()
        
        self.attributedText = attributedText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
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
            .underlineColor: Theme.colors.iosBlue]
    }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        
        if isEditable {
            return CGSize(width: 200, height: max(114, superSize.height))
        } else {
            return superSize
        }
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
    /// - Tag: TextView.linkTouched
    @discardableResult
    func linkTouched(handler: @escaping (URL) -> Void) -> Self {
        isSelectable = true
        linkHandlers.append(handler)
        return self
    }
    
    /// Add a listener for updated text. Calling this method will set `isSelectable` and `isEditable` to `true`
    ///
    /// - parameter handler: The closure to be called when the text is updated
    /// - Tag: TextView.textChanged
    @discardableResult
    func textChanged(handler: @escaping (String?) -> Void) -> Self {
        isSelectable = true
        isEditable = true
        textChangedHandlers.append(handler)
        return self
    }
    
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		switch interaction {
			case .invokeDefaultAction:
				linkHandlers.forEach { $0(URL) }
			default:
				return false
		}
		
		return false
	}
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textChangedHandlers.forEach { $0(textView.text) }
    }
}

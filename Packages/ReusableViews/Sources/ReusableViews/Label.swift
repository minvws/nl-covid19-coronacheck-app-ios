/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared

/*
 Styled UILabel subclass providing convenience initialization for each text style support in the Theme
 */
open class Label: UILabel {
	
	public init(_ text: String?, font: UIFont = Fonts.body, textColor: UIColor = C.black()!) {
		super.init(frame: .zero)
		
		self.text = text
		self.font = font
		self.textColor = textColor
		self.translatesAutoresizingMaskIntoConstraints = false
		self.adjustsFontForContentSizeCategory = true
	}
	
	required public init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	public convenience init(largeTitle: String?, textColor: UIColor = C.primaryText()!) {
		self.init(largeTitle, font: Fonts.largeTitle, textColor: textColor)
	}
	
	public convenience init(title1: String?, textColor: UIColor = C.primaryText()!, montserrat: Bool = false) {
		if montserrat {
			self.init(title1, font: Fonts.title1Montserrat, textColor: textColor)
		} else {
			self.init(title1, font: Fonts.title1, textColor: textColor)
		}
	}
	
	public convenience init(title2: String?, textColor: UIColor = C.primaryText()!) {
		self.init(title2, font: Fonts.title2, textColor: textColor)
	}
	
	public convenience init(title3: String?, textColor: UIColor = C.primaryText()!, montserrat: Bool = false) {
		if montserrat {
			self.init(title3, font: Fonts.title3Montserrat, textColor: textColor)
		} else {
			self.init(title3, font: Fonts.title3, textColor: textColor)
		}
	}
	
	public convenience init(title3Medium: String?, textColor: UIColor = C.primaryText()!) {
		self.init(title3Medium, font: Fonts.title3Medium, textColor: textColor)
	}

	public convenience init(headline: String?, textColor: UIColor = C.primaryText()!) {
		self.init(headline, font: Fonts.headline, textColor: textColor)
	}
	
	public convenience init(headlineBold: String?, textColor: UIColor = C.primaryText()!, montserrat: Bool = false) {
		if montserrat {
			self.init(headlineBold, font: Fonts.headlineBoldMontserrat, textColor: textColor)
		} else {
			self.init(headlineBold, font: Fonts.headlineBold, textColor: textColor)
		}
	}
	
	public convenience init(body: String?, textColor: UIColor = C.primaryText()!) {
		self.init(body, font: Fonts.body, textColor: textColor)
	}
	
	public convenience init(bodyBold: String?, textColor: UIColor = C.primaryText()!) {
		self.init(bodyBold, font: Fonts.bodyBold, textColor: textColor)
	}
	
	public convenience init(bodySemiBold: String?, textColor: UIColor = C.primaryText()!) {
		self.init(bodySemiBold, font: Fonts.bodySemiBold, textColor: textColor)
	}
	
	public convenience init(bodyMedium: String?, textColor: UIColor = C.primaryText()!) {
		self.init(bodyMedium, font: Fonts.bodyMedium, textColor: textColor)
	}
	
	public convenience init(callout: String?, textColor: UIColor = C.primaryText()!) {
		self.init(callout, font: Fonts.callout, textColor: textColor)
	}
	
	public convenience init(calloutSemiBold: String?, textColor: UIColor = C.primaryText()!) {
		self.init(calloutSemiBold, font: Fonts.calloutSemiBold, textColor: textColor)
	}
	
	public convenience init(subhead: String?, textColor: UIColor = C.primaryText()!) {
		self.init(subhead, font: Fonts.subhead, textColor: textColor)
	}
	
	public convenience init(subheadBold: String?, textColor: UIColor = C.primaryText()!) {
		self.init(subheadBold, font: Fonts.subheadBold, textColor: textColor)
	}
	
	public convenience init(subheadHeavyBold: String?, textColor: UIColor = C.primaryText()!) {
		self.init(subheadHeavyBold, font: Fonts.subheadHeavyBold, textColor: textColor)
	}
	
	public convenience init(subheadMedium: String?, textColor: UIColor = C.primaryText()!) {
		self.init(subheadMedium, font: Fonts.subheadMedium, textColor: textColor)
	}
	
	public convenience init(footnote: String?, textColor: UIColor = C.primaryText()!) {
		self.init(footnote, font: Fonts.footnote, textColor: textColor)
	}
	
	public convenience init(caption1: String?, textColor: UIColor = C.primaryText()!) {
		self.init(caption1, font: Fonts.caption1, textColor: textColor)
	}
	
	public convenience init(caption1SemiBold: String?, textColor: UIColor = C.primaryText()!) {
		self.init(caption1SemiBold, font: Fonts.caption1SemiBold, textColor: textColor)
	}
	
	@discardableResult
	open func multiline() -> Self {
		numberOfLines = 0
		return self
	}
	
	@discardableResult
	open func header(_ isHeader: Bool = true) -> Self {
		if isHeader {
			accessibilityTraits.insert(.header)
		} else {
			accessibilityTraits.remove(.header)
		}
		return self
	}
	
	// Can become focused if it contains a link (or is underlined like a link)
	override open var canBecomeFocused: Bool {
		guard let attributedText = attributedText else { return false }
		return attributedText.attributes { key, value, range in
			return key == .underlineStyle || key == .link
		}
	}
}
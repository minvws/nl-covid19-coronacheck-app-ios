/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// Styled UILabel subclass providing convenience initialization for each text style support in the Theme
class Label: UILabel {
    
	init(_ text: String?, font: UIFont = Fonts.body, textColor: UIColor = C.black()!) {
		super.init(frame: .zero)
		
		self.text = text
		self.font = font
		self.textColor = textColor
		self.translatesAutoresizingMaskIntoConstraints = false
		self.adjustsFontForContentSizeCategory = true
	}
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(largeTitle: String?, textColor: UIColor = .darkText) {
        self.init(largeTitle, font: Fonts.largeTitle, textColor: textColor)
    }
    
	convenience init(title1: String?, textColor: UIColor = .darkText, montserrat: Bool = false) {
		if montserrat {
			self.init(title1, font: Fonts.title1Montserrat, textColor: textColor)
		} else {
			self.init(title1, font: Fonts.title1, textColor: textColor)
		}
	}

    convenience init(title2: String?, textColor: UIColor = .darkText) {
        self.init(title2, font: Fonts.title2, textColor: textColor)
    }

	convenience init(title3: String?, textColor: UIColor = .darkText, montserrat: Bool = false) {
		if montserrat {
			self.init(title3, font: Fonts.title3Montserrat, textColor: textColor)
		} else {
			self.init(title3, font: Fonts.title3, textColor: textColor)
		}
	}

	convenience init(title3Medium: String?, textColor: UIColor = .darkText) {
		self.init(title3Medium, font: Fonts.title3Medium, textColor: textColor)
	}
    
    convenience init(headline: String?, textColor: UIColor = .darkText) {
        self.init(headline, font: Fonts.headline, textColor: textColor)
    }

	convenience init(headlineBold: String?, textColor: UIColor = .darkText, montserrat: Bool = false) {
		if montserrat {
			self.init(headlineBold, font: Fonts.headlineBoldMontserrat, textColor: textColor)
		} else {
			self.init(headlineBold, font: Fonts.headlineBold, textColor: textColor)
		}
	}
    
    convenience init(body: String?, textColor: UIColor = .darkText) {
        self.init(body, font: Fonts.body, textColor: textColor)
    }
    
    convenience init(bodyBold: String?, textColor: UIColor = .darkText) {
        self.init(bodyBold, font: Fonts.bodyBold, textColor: textColor)
    }

	convenience init(bodySemiBold: String?, textColor: UIColor = .darkText) {
		self.init(bodySemiBold, font: Fonts.bodySemiBold, textColor: textColor)
	}

	convenience init(bodyMedium: String?, textColor: UIColor = .darkText) {
		self.init(bodyMedium, font: Fonts.bodyMedium, textColor: textColor)
	}

    convenience init(callout: String?, textColor: UIColor = .darkText) {
        self.init(callout, font: Fonts.callout, textColor: textColor)
    }

	convenience init(calloutSemiBold: String?, textColor: UIColor = .darkText) {
		self.init(calloutSemiBold, font: Fonts.calloutSemiBold, textColor: textColor)
	}
    
    convenience init(subhead: String?, textColor: UIColor = .darkText) {
        self.init(subhead, font: Fonts.subhead, textColor: textColor)
    }
    
    convenience init(subheadBold: String?, textColor: UIColor = .darkText) {
        self.init(subheadBold, font: Fonts.subheadBold, textColor: textColor)
    }
	
	convenience init(subheadHeavyBold: String?, textColor: UIColor = .darkText) {
		self.init(subheadHeavyBold, font: Fonts.subheadHeavyBold, textColor: textColor)
	}

	convenience init(subheadMedium: String?, textColor: UIColor = .darkText) {
		self.init(subheadMedium, font: Fonts.subheadMedium, textColor: textColor)
	}
    
    convenience init(footnote: String?, textColor: UIColor = .darkText) {
        self.init(footnote, font: Fonts.footnote, textColor: textColor)
    }
    
    convenience init(caption1: String?, textColor: UIColor = .darkText) {
        self.init(caption1, font: Fonts.caption1, textColor: textColor)
    }

	convenience init(caption1SemiBold: String?, textColor: UIColor = .darkText) {
		self.init(caption1SemiBold, font: Fonts.caption1SemiBold, textColor: textColor)
	}
    
    @discardableResult
    func multiline() -> Self {
        numberOfLines = 0
        return self
    }
    
    @discardableResult
    func header(_ isHeader: Bool = true) -> Self {
        if isHeader {
            accessibilityTraits.insert(.header)
        } else {
            accessibilityTraits.remove(.header)
        }
		return self
    }
	
	// Can become focused if it contains a link (or is underlined like a link)
	override var canBecomeFocused: Bool {
		guard let attributedText = attributedText else { return false }
		return attributedText.attributes { key, value, range in
			return key == .underlineStyle || key == .link
		}
	}
}

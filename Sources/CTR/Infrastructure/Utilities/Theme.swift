/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class Fonts {
    // Using default textStyles from Apple typography guidelines:
    // https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
    // Table with point in sizes can be found on the link.
	
	enum Weight {
		case medium
		case semiBold
		case bold
		case heavyBold
	}

	/// Size 34 points
    var largeTitle: UIFont {
		font(textStyle: .largeTitle, weight: .bold)
    }

	/// Size 28 points
    var title1: UIFont {
        font(textStyle: .title1, weight: .bold)
    }

	/// Size 26 points
	var title1Montserrat: UIFont {
		Fonts.customMontserratFont(forTextStyle: .title1)
	}

	/// Size 22 points
    var title2: UIFont {
        font(textStyle: .title2, weight: .bold)
    }

	/// Size 20 points
    var title3: UIFont {
        font(textStyle: .title3, weight: .bold)
    }

	/// Size 20 points
	var title3Montserrat: UIFont {
		font(textStyle: .title3, weight: .bold, customFont: "Montserrat-Bold")
	}

	/// Size 20 points
	var title3Medium: UIFont {
		font(textStyle: .title3, weight: .medium)
	}

	/// Size 17 points
    var headline: UIFont {
        font(textStyle: .headline)
    }

	/// Size 17 points
	var headlineBold: UIFont {
		font(textStyle: .headline, weight: .bold)
	}
	
	/// Size 17 points
	var headlineBoldMontserrat: UIFont {
		font(textStyle: .headline, weight: .bold, customFont: "Montserrat-Bold")
	}

	/// Size 17 points
    var body: UIFont {
        font(textStyle: .body)
    }

	/// Size 17 points
	var bodyMontserrat: UIFont {
		font(textStyle: .body, customFont: "Montserrat-Bold")
	}

	/// Size 17 points
	var bodyMontserratFixed: UIFont {

		if let font = UIFont(name: "Montserrat-Bold", size: 17) {
			return font
		}
		return .systemFont(ofSize: 17)
	}

	/// Size 17 points
    var bodyBold: UIFont {
        font(textStyle: .body, weight: .bold)
    }

	/// Size 17 points
	var bodyBoldFixed: UIFont {
		return .boldSystemFont(ofSize: 17)
	}

	/// Size 17 points
	var bodySemiBold: UIFont {
		font(textStyle: .body, weight: .semiBold)
	}

	/// Size 17 points
	var bodyMedium: UIFont {
		font(textStyle: .body, weight: .medium)
	}

	/// Size 16 points
    var callout: UIFont {
        font(textStyle: .callout)
    }
	
	/// Size 16 points
	var calloutSemiBold: UIFont {
		font(textStyle: .callout, weight: .semiBold)
	}

	/// Size 15 points
    var subhead: UIFont {
        font(textStyle: .subheadline)
    }

	/// Size 15 points
	var subheadMontserrat: UIFont {
		font(textStyle: .subheadline, customFont: "Montserrat-SemiBold")
	}
	
	/// Size 15 points
	var subheadHeavyBold: UIFont {
		font(textStyle: .subheadline, weight: .heavyBold)
	}

	/// Size 15 points
    var subheadBold: UIFont {
		font(textStyle: .subheadline, weight: .bold)
    }

	/// Size 15 points
	var subheadMedium: UIFont {
		font(textStyle: .subheadline, weight: .medium)
	}

	/// Size 13 points
    var footnote: UIFont {
        font(textStyle: .footnote)
    }

	/// Size 13 points
	var footnoteMontserrat: UIFont {
		font(textStyle: .footnote, customFont: "Montserrat-SemiBold")
	}

	/// size 12 points
    var caption1: UIFont {
		font(textStyle: .caption1, weight: .bold)
    }

	/// size 12 points
	var caption1SemiBold: UIFont {
		font(textStyle: .caption1, weight: .semiBold)
	}

    // MARK: - Private

	private static let customMontserratTextStyles: [UIFont.TextStyle: UIFont] = [
		.largeTitle: UIFont(name: "Montserrat-Bold", size: 34)!,
		.title1: UIFont(name: "Montserrat-Bold", size: 26)!, // this value is changed from default of 28
		.title2: UIFont(name: "Montserrat-Bold", size: 22)!,
		.title3: UIFont(name: "Montserrat-Bold", size: 20)!,
		.headline: UIFont(name: "Montserrat-Bold", size: 17)!,
		.body: UIFont(name: "Montserrat-Bold", size: 17)!,
		.callout: UIFont(name: "Montserrat-Bold", size: 16)!,
		.subheadline: UIFont(name: "Montserrat-Bold", size: 15)!,
		.footnote: UIFont(name: "Montserrat-Bold", size: 13)!,
		.caption1: UIFont(name: "Montserrat-Bold", size: 12)!,
		.caption2: UIFont(name: "Montserrat-Bold", size: 11)!
	]
	
	private func font(
		textStyle: UIFont.TextStyle,
		weight: Weight? = nil,
		customFont: String? = nil) -> UIFont {

		if let customFontName = customFont {
			let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
			if let customFont = UIFont(name: customFontName, size: descriptor.pointSize) {
				return customFont
			}
		}

        var fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
		
		if weight == .heavyBold {
			fontDescriptor = fontDescriptor.addingAttributes(
				[.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]]
			)
		}

        if weight == .bold, let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            fontDescriptor = boldFontDescriptor
        }

		if weight == .semiBold {
			fontDescriptor = fontDescriptor.addingAttributes(
				[.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]]
			)
		}

		if weight == .medium {
			fontDescriptor = fontDescriptor.addingAttributes(
				[.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.medium]]
			)
		}

		return UIFont(descriptor: fontDescriptor, size: fontDescriptor.pointSize)
    }
	
	private class func customMontserratFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
		let metrics = UIFontMetrics(forTextStyle: style)
		let scaledFont = metrics.scaledFont(for: customMontserratTextStyles[style]!)
		
		return scaledFont
	}
}

final class Colors {

	var primary: UIColor { return color(for: "PrimaryColor") }

	var secondary: UIColor { return color(for: "SecondaryColor") }
	
	var secondaryText: UIColor { return color(for: "SecondaryText") }

    var tertiary: UIColor { return color(for: "TertiaryColor") }

	var gray: UIColor { return color(for: "DotGray") }

	var disabledIcon: UIColor { return color(for: "DisabledIcon") }

	var viewControllerBackground: UIColor { return color(for: "ViewControllerBackgroundColor") }

	var appointment: UIColor { return color(for: "AppointmentColor") }

	var shadow: UIColor { return color(for: "ShadowColor") }

	var lightBackground: UIColor { return color(for: "LightBackgroundColor") }

	var line: UIColor { return color(for: "LineColor") }

	var utilityError: UIColor { return color(for: "UtilityError") }

	var denied: UIColor { return color(for: "DeniedColor") }

	var access: UIColor { return color(for: "AccessColor") }

	var grey1: UIColor { return color(for: "Grey1") }

	var grey2: UIColor { return color(for: "Grey2") }

	var grey3: UIColor { return color(for: "Grey3") }

	var grey4: UIColor { return color(for: "Grey4") }

	var grey5: UIColor { return color(for: "Grey5") }

	var highlightBackgroundColor: UIColor { return color(for: "HighlightBackgroundColor") }
	
	var emptyDashboardColor: UIColor { return color(for: "EmptyDashboardColor") }

    // MARK: - Private

    private func color(for name: String) -> UIColor {
		
        let bundle = Bundle(for: Colors.self)
        if let color = UIColor(named: name, in: bundle, compatibleWith: nil) {
            return color
        }
        return .clear
    }
}

/// - Tag: Theme
struct Theme {

    static let fonts = Fonts()
    static let colors = Colors()
}

/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared

public class Fonts {
	// Using default textStyles from Apple typography guidelines:
	// https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
	// Table with point in sizes can be found on the link.
	
	public enum Weight {
		case medium
		case semiBold
		case bold
		case heavyBold
	}
	
	/// Size 34 points
	public static var largeTitle: UIFont {
		font(textStyle: .largeTitle, weight: .bold)
	}
	
	/// Size 28 points
	public static var title1: UIFont {
		font(textStyle: .title1, weight: .bold)
	}
	
	/// Size 26 points
	public static var title1Montserrat: UIFont {
		Fonts.customMontserratFont(forTextStyle: .title1)
	}
	
	/// Size 22 points
	public static var title2: UIFont {
		font(textStyle: .title2, weight: .bold)
	}
	
	/// Size 20 points
	public static var title3: UIFont {
		font(textStyle: .title3, weight: .bold)
	}
	
	/// Size 20 points
	public static var title3Montserrat: UIFont {
		font(textStyle: .title3, weight: .bold, customFont: "Montserrat-Bold")
	}
	
	/// Size 20 points
	public static var title3Medium: UIFont {
		font(textStyle: .title3, weight: .medium)
	}
	
	/// Size 17 points
	public static var headline: UIFont {
		font(textStyle: .headline)
	}
	
	/// Size 17 points
	public static var headlineBold: UIFont {
		font(textStyle: .headline, weight: .bold)
	}
	
	/// Size 17 points
	public static var headlineBoldMontserrat: UIFont {
		font(textStyle: .headline, weight: .bold, customFont: "Montserrat-Bold")
	}
	
	/// Size 17 points
	public static var body: UIFont {
		font(textStyle: .body)
	}
	
	/// Size 17 points
	public static var bodyMontserrat: UIFont {
		font(textStyle: .body, customFont: "Montserrat-Bold")
	}
	
	/// Size 17 points
	public static var bodyMontserratFixed: UIFont {
		
		if let font = UIFont(name: "Montserrat-Bold", size: 17) {
			return font
		}
		return .systemFont(ofSize: 17)
	}
	
	/// Size 17 points
	public static var bodyBold: UIFont {
		font(textStyle: .body, weight: .bold)
	}
	
	/// Size 17 points
	public static var bodyBoldFixed: UIFont {
		return .boldSystemFont(ofSize: 17)
	}
	
	/// Size 17 points
	public static var bodySemiBold: UIFont {
		font(textStyle: .body, weight: .semiBold)
	}
	
	/// Size 17 points
	public static var bodyMedium: UIFont {
		font(textStyle: .body, weight: .medium)
	}
	
	/// Size 16 points
	public static var callout: UIFont {
		font(textStyle: .callout)
	}
	
	/// Size 16 points
	public static var calloutSemiBold: UIFont {
		font(textStyle: .callout, weight: .semiBold)
	}
	
	/// Size 15 points
	public static var subhead: UIFont {
		font(textStyle: .subheadline)
	}
	
	/// Size 15 points
	public static var subheadMontserrat: UIFont {
		font(textStyle: .subheadline, customFont: "Montserrat-SemiBold")
	}
	
	/// Size 15 points
	public static var subheadHeavyBold: UIFont {
		font(textStyle: .subheadline, weight: .heavyBold)
	}
	
	/// Size 15 points
	public static var subheadBold: UIFont {
		font(textStyle: .subheadline, weight: .bold)
	}
	
	/// Size 15 points
	public static var subheadMedium: UIFont {
		font(textStyle: .subheadline, weight: .medium)
	}
	
	/// Size 13 points
	public static var footnote: UIFont {
		font(textStyle: .footnote)
	}
	
	/// Size 13 points
	public static var footnoteMontserrat: UIFont {
		font(textStyle: .footnote, customFont: "Montserrat-SemiBold")
	}
	
	/// size 12 points
	public static var caption1: UIFont {
		font(textStyle: .caption1, weight: .bold)
	}
	
	/// size 12 points
	public static var caption1SemiBold: UIFont {
		font(textStyle: .caption1, weight: .semiBold)
	}
	
	// MARK: - Private
	
	private static let customMontserratTextStyles: [UIFont.TextStyle: UIFont] = {
		return [
			.largeTitle: R.font.montserratBold(size: 34)!,
			.title1: R.font.montserratBold(size: 26)!, // this value is changed from default of 28
			.title2: R.font.montserratBold(size: 22)!,
			.title3: R.font.montserratBold(size: 20)!,
			.headline: R.font.montserratBold(size: 17)!,
			.body: R.font.montserratBold(size: 17)!,
			.callout: R.font.montserratBold(size: 16)!,
			.subheadline: R.font.montserratBold(size: 15)!,
			.footnote: R.font.montserratBold(size: 13)!,
			.caption1: R.font.montserratBold(size: 12)!,
			.caption2: R.font.montserratBold(size: 11)!
		]
	}()
	
	private class func font(
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
		
		guard let montserratFont = customMontserratTextStyles[style] else {
			logWarning("Could not load montserrat font")
			return UIFont.preferredFont(forTextStyle: style)
		}
		return metrics.scaledFont(for: montserratFont)
	}
}

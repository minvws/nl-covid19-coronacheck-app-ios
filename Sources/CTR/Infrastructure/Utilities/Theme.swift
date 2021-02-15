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

    var largeTitle: UIFont {
        font(textStyle: .largeTitle, isBold: true) // Size 34 points
    }

    var title1: UIFont {
        font(textStyle: .title1, isBold: true) // Size 28 points
    }

    var title2: UIFont {
        font(textStyle: .title2, isBold: true) // Size 22 points
    }

    var title3: UIFont {
        font(textStyle: .title3, isBold: true) // Size 20 points
    }

    var headline: UIFont {
        font(textStyle: .headline) // Size 17 points
    }

    var body: UIFont {
        font(textStyle: .body) // Size 17 points
    }

    var bodyBold: UIFont {
        font(textStyle: .body, isBold: true) // Size 17 points
    }

    var callout: UIFont {
        font(textStyle: .callout) // Size 16 points
    }

    var subhead: UIFont {
        font(textStyle: .subheadline) // Size 15 points
    }

    var subheadBold: UIFont {
        font(textStyle: .subheadline, isBold: true) // Size 15 points
    }

    var footnote: UIFont {
        font(textStyle: .footnote) // Size 13 points
    }

    var caption1: UIFont {
        font(textStyle: .caption1, isBold: true) // size 12 points
    }

    // MARK: - Private

    private func font(textStyle: UIFont.TextStyle, isBold: Bool = false) -> UIFont {

        var fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)

        if isBold, let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) {
            fontDescriptor = boldFontDescriptor
        }

        return UIFont(descriptor: fontDescriptor, size: fontDescriptor.pointSize)
    }
}

final class Colors {

	var dark: UIColor { return color(for: "DarkColor") }

	var primary: UIColor { return color(for: "PrimaryColor") }

	var secondary: UIColor { return color(for: "SecondaryColor") }

	var iosBlue: UIColor { return color(for: "IosBlue") }

    var tertiary: UIColor { return color(for: "TertiaryColor") }

	var gray: UIColor { return color(for: "DotGray") }

	var disabledIcon: UIColor { return color(for: "DisabledIcon") }

	var viewControllerBackground: UIColor { return color(for: "ViewControllerBackgroundColor") }

	var appointment: UIColor { return color(for: "AppointmentColor") }

	var create: UIColor { return color(for: "CreateColor") }

	var shadow: UIColor { return color(for: "ShadowColor") }

	var lightBackground: UIColor { return color(for: "LightBackgroundColor") }

	var line: UIColor { return color(for: "LineColor") }

	var error: UIColor { return color(for: "ErrorColor") }

	var denied: UIColor { return color(for: "DeniedColor") }

	var access: UIColor { return color(for: "AccessColor") }

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

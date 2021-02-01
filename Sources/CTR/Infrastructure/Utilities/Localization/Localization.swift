/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit

public final class Localization {

    /// Get the Localized string for the current bundle.
    /// If the key has not been localized this will fallback to the Base project strings
    public static func string(for key: String, comment: String = "", _ arguments: [CVarArg] = []) -> String {
        let value = NSLocalizedString(key, bundle: Bundle(for: Localization.self), comment: comment)
        guard value == key else {
            return !arguments.isEmpty ? String(format: value, arguments: arguments) : value
        }
        guard
            let path = Bundle(for: Localization.self).path(forResource: "Base", ofType: "lproj"),
            let bundle = Bundle(path: path) else {
            return !arguments.isEmpty ? String(format: value, arguments: arguments) : value
        }
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        return !arguments.isEmpty ? String(format: localizedString, arguments: arguments) : localizedString
    }

    public static func attributedString(for key: String, comment: String = "", _ arguments: [CVarArg] = []) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string(for: key, arguments))
    }

    public static func attributedStrings(for key: String, comment: String = "", _ arguments: [CVarArg] = []) -> [NSMutableAttributedString] {
        let value = string(for: key, arguments)
        let paragraph = "\n\n"
        let strings = value.components(separatedBy: paragraph)

        return strings.enumerated().map { index, element -> NSMutableAttributedString in
            let value = index < strings.count - 1 ? element + "\n" : element
            return NSMutableAttributedString(string: value)
        }
    }

    public static var isRTL: Bool { return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft }
}

extension String {
    
    /* MARK: - General */
//    static var yes: String { return Localization.string(for: "yes") }
//    static var no: String { return Localization.string(for: "no") }
//    static var save: String { return Localization.string(for: "save") }
//    static var cancel: String { return Localization.string(for: "cancel") }
//    static var close: String { return Localization.string(for: "close") }
//    static var next: String { return Localization.string(for: "next") }
//    static var start: String { return Localization.string(for: "start") }
//    static var edit: String { return Localization.string(for: "edit") }
//    static var selectDate: String { return Localization.string(for: "selectDate") }
//    static var done: String { return Localization.string(for: "done") }
    static var ok: String {
		
		return Localization.string(for: "general.ok")
	}
//    static var tryAgain: String { return Localization.string(for: "tryAgain") }
//    static var delete: String { return Localization.string(for: "delete") }

	static var errorTitle: String {

		return Localization.string(for: "general.error.title")
	}

	static var learnMore: String {

		return Localization.string(for: "general.learnMore")
	}
}

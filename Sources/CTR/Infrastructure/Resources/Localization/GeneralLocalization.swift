/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit

extension String {
    
    /* MARK: - General */
//    static var yes: String { return Localization.string(for: "yes") }
//    static var no: String { return Localization.string(for: "no") }
//    static var save: String { return Localization.string(for: "save") }
//    static var cancel: String { return Localization.string(for: "cancel") }

	static var close: String {

		return Localization.string(for: "general.close")
	}

	static var next: String {

		return Localization.string(for: "general.next")
	}
//    static var start: String { return Localization.string(for: "start") }
//    static var edit: String { return Localization.string(for: "edit") }
//    static var selectDate: String { return Localization.string(for: "selectDate") }

	static var done: String {

		return Localization.string(for: "general.done")
	}

    static var ok: String {
		
		return Localization.string(for: "general.ok")
	}
//    static var tryAgain: String { return Localization.string(for: "tryAgain") }
//    static var delete: String { return Localization.string(for: "delete") }

	static var previous: String {

		return Localization.string(for: "general.previous")
	}

	static var errorTitle: String {

		return Localization.string(for: "general.error.title")
	}

	static var learnMore: String {

		return Localization.string(for: "general.learnMore")
	}
}

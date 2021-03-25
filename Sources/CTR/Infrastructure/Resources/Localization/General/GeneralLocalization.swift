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

	static var close: String {

		return Localization.string(for: "general.close")
	}

	static var next: String {

		return Localization.string(for: "general.next")
	}

	static var done: String {

		return Localization.string(for: "general.done")
	}

    static var ok: String {
		
		return Localization.string(for: "general.ok")
	}

	static var previous: String {

		return Localization.string(for: "general.previous")
	}

	static var errorTitle: String {

		return Localization.string(for: "general.error.title")
	}

	static var technicalErrorText: String {

		return Localization.string(for: "general.error.technical.text")
	}

	static var menuVersion: String {

		return Localization.string(for: "general.menu.version")
	}
}

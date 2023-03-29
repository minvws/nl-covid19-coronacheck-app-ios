/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
import Resources

/// Basic sanity check that ensures that we are able to retrieve localized strings for all languages
/// we support.
final class LocalizedCopyTests: XCTestCase {

	fileprivate enum AvailableLocale: String, CaseIterable {
		case en
		case nl
	}

	func testAllLocalizationsCanBeAccessed() {
		AvailableLocale.allCases.forEach { locale in
			expect(self.copyValue(key: "general.add", forLocaleIdentifier: locale)) != nil
		}
	}

	func testCommonlyWronglyEditedCopy() {

		/* -- These should all be lowercased 👇🏻 -- */
		expect(self.copyValues(key: "general.recoverydate"))
			== [ .nl: "hersteldatum", .en: "recovery date" ]

		expect(self.copyValues(key: "general_vaccination"))
			== [ .nl: "vaccinatie", .en: "vaccination" ]

		expect(self.copyValues(key: "general_vaccinationcertificate"))
			== [ .nl: "vaccinatiebewijs", .en: "vaccination certificate" ]

		expect(self.copyValues(key: "general_testcertificate"))
			== [ .nl: "testbewijs", .en: "test certificate" ]

		expect(self.copyValues(key: "general.recoverydate"))
			== [ .nl: "hersteldatum", .en: "recovery date" ]

		expect(self.copyValues(key: "general_recoverycertificate"))
			== [ .nl: "herstelbewijs", .en: "recovery certificate" ]
		/* -- (end of lowercased checks) ☝🏻 -- */

		expect(self.copyValues(key: "general.testdate"))
			== [ .nl: "Testdatum", .en: "test date" ]

		expect(self.copyValues(key: "general.vaccinationdate"))
			== [ .nl: "Vaccinatiedatum", .en: "Vaccination date" ]
	}
}

fileprivate extension LocalizedCopyTests {

	func copyValues(key: String, localIdentifiers: [AvailableLocale] = AvailableLocale.allCases) -> [AvailableLocale: String] {
		return localIdentifiers.reduce([:]) { result, locale in
			guard let value = copyValue(key: key, forLocaleIdentifier: locale) else { return result }
			var mut = result
			mut[locale] = value
			return mut
		}
	}

	func copyValue(key: String, forLocaleIdentifier localeIdentifier: AvailableLocale) -> String? {
		guard let path = Resources.R.bundle.path(forResource: localeIdentifier.rawValue, ofType: "lproj"),
			  let bundle = Bundle(path: path) else {
			XCTFail("Missing localization for \(localeIdentifier.rawValue)")
			return nil
		}

		let string = bundle.localizedString(forKey: key, value: nil, table: nil)

		XCTAssertFalse(string.isEmpty)
		XCTAssertNotEqual(string, key)

		return string
	}

}
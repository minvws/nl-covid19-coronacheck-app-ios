/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// MARK: - Holder

extension String {

	static var holderChooseQRCodeTypeTitle: String {

		return Localization.string(for: "holder.chooseqrcodetype.title")
	}

	static func holderChooseQRCodeTypeMessage(testHoursValidity: Int, vaccineDaysValidity: Int) -> String {

		let formattedTestHoursValidity: String = {
			let hoursFormatter = DateComponentsFormatter()
			hoursFormatter.unitsStyle = .full
			hoursFormatter.collapsesLargestUnit = true
			hoursFormatter.allowedUnits = [.hour]

			let components = DateComponents(hour: testHoursValidity)
			return hoursFormatter.string(from: components) ?? "-"
		}()

		let formattedVaccineDaysValidity: String = {
			let daysFormatter = DateComponentsFormatter()
			daysFormatter.unitsStyle = .full
			daysFormatter.collapsesLargestUnit = true
			daysFormatter.allowedUnits = [.day, .year]

			let components = DateComponents(day: vaccineDaysValidity)
			return daysFormatter.string(from: components) ?? "-"
		}()

		return Localization.string(for: "holder.chooseqrcodetype.message", comment: "", [formattedTestHoursValidity, formattedVaccineDaysValidity])
	}

	static var holderChooseQRCodeTypeOptionNegativeTestTitle: String {

		return Localization.string(for: "holder.chooseqrcodetype.option.negativetest.title")
	}

	static var holderChooseQRCodeTypeOptionNegativeTestSubtitle: String {

		return Localization.string(for: "holder.chooseqrcodetype.option.negativetest.subtitle")
	}

	static var holderChooseQRCodeTypeOptionVaccineTitle: String {

		return Localization.string(for: "holder.chooseqrcodetype.option.vaccine.title")
	}

	static var holderChooseQRCodeTypeOptionVaccineSubtitle: String {

		return Localization.string(for: "holder.chooseqrcodetype.option.vaccine.subtitle")
	}
}

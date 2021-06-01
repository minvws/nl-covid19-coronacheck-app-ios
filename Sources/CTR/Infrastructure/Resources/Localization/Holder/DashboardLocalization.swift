/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

extension String {

	static var holderDashboardTitle: String {

		return Localization.string(for: "holder.dashboard.title")
	}

	static var holderDashboardIntro: String {

		return Localization.string(for: "holder.dashboard.intro")
	}

	static var holderDashboardCreateTitle: String {

		return Localization.string(for: "holder.dashboard.create.title")
	}

	static var holderDashboardCreateMessage: String {

		return Localization.string(for: "holder.dashboard.create.message")
	}

	static var holderDashboardCreateAction: String {

		return Localization.string(for: "holder.dashboard.create.action")
	}

	static func holderDashboardQRExpired(localizedRegion: String, localizedOriginType: String) -> String {

		return Localization.string(for: "holder.dashboard.qr.expired", comment: "", [localizedRegion, localizedOriginType])
	}

	static func holderDashboardOriginNotValidInEuropeButIsInTheNetherlands(localizedOriginType: String) -> String {
		return Localization.string(for: "holder.dashboard.originNotValidInEUButIsInTheNetherlands", comment: "", [localizedOriginType])
	}

	static func holderDashboardOriginNotValidInNetherlandsButIsInEurope(localizedOriginType: String) -> String {
		return Localization.string(for: "holder.dashboard.originNotValidInNetherlandsButIsInEU", comment: "", [localizedOriginType])
	}

	static var hour: String {

		return Localization.string(for: "holder.dashboard.qr.hour")
	}

	static var minute: String {

		return Localization.string(for: "holder.dashboard.qr.minute")
	}

	static var longMinutes: String {

		return Localization.string(for: "holder.dashboard.qr.minutes.long")
	}

	static var longMinute: String {

		return Localization.string(for: "holder.dashboard.qr.minute.long")
	}

	static var am: String {

		return Localization.string(for: "holder.dashboard.qr.am")
	}

	static var pm: String {

		return Localization.string(for: "holder.dashboard.qr.pm")
	}

	static var changeRegionTitleNL: String {
		return Localization.string(for: "holder.dashboard.changeregion.title.nl")
	}

	static var changeRegionTitleEU: String {
		return Localization.string(for: "holder.dashboard.changeregion.title.eu")
	}

	static var changeRegionButton: String {
		return Localization.string(for: "holder.dashboard.changeregion.button")
	}

	static var qrTitle: String {
		return Localization.string(for: "holder.dashboard.qr.title")
	}

	static var qrButtonViewQR: String {
		return Localization.string(for: "holder.dashboard.qr.button.viewQR")
	}

	static var qrExpiryDatePrefixExpiresIn: String {
		return Localization.string(for: "holder.dashboard.qr.expiryDate.prefix.expiresIn")
	}

	static var qrExpiryDatePrefixValidUpToAndIncluding: String {
		return Localization.string(for: "holder.dashboard.qr.expiryDate.prefix.validUptoAndIncluding")
	}

	static var qrValidityDatePrefixValidFrom: String {
		return Localization.string(for: "holder.dashboard.qr.validityDate.prefix.validFrom")
	}

	static var qrValidityDatePrefixAutomaticallyBecomesValidOn: String {
		return Localization.string(for: "holder.dashboard.qr.validityDate.prefix.automaticallyBecomesValidOn")
	}

	static var qrTypeRecovery: String {
		return Localization.string(for: "holder.dashboard.qr.type.recovery")
	}

	static var qrTypeNegativeTest: String {
		return Localization.string(for: "holder.dashboard.qr.type.negativeTest")
	}

	static var qrTypeVaccination: String {
		return Localization.string(for: "holder.dashboard.qr.type.vaccination")
	}
}

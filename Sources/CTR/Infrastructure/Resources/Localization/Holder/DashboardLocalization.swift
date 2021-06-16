/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

extension String {

	static func holderDashboardQRExpired(localizedRegion: String, localizedOriginType: String) -> String {
		// Localization.string(for: "holder.dashboard.qr.expired", comment: "", [localizedRegion, localizedOriginType])
		// Coming soon: this string will contain above parameters.
		L.holderDashboardQrExpired()
	}

	static func holderDashboardNotValidInThisRegionScreenTitle(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion) -> String {
		switch (originType, currentRegion) {
			case (.vaccination, .domestic):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.domestic.vaccination.title")
			case (.vaccination, .europeanUnion):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.eu.vaccination.title")
			case (.test, .domestic):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.domestic.test.title")
			case (.test, .europeanUnion):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.eu.test.title")
			case (.recovery, .domestic):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.domestic.recovery.title")
			case (.recovery, .europeanUnion):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.eu.recovery.title")
		}
	}

	static func holderDashboardNotValidInThisRegionScreenMessage(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion) -> String {
		switch (originType, currentRegion) {
			case (.vaccination, .domestic):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.domestic.vaccination.message")
			case (.vaccination, .europeanUnion):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.eu.vaccination.message")
			case (.test, .domestic):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.domestic.test.message")
			case (.test, .europeanUnion):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.eu.test.message")
			case (.recovery, .domestic):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.domestic.recovery.message")
			case (.recovery, .europeanUnion):
				return Localization.string(for: "holder.dashboard.notValidInThisRegionScreen.eu.recovery.message")
		}
	}
    
	// Can be deleted after EU launch: 
	static func qrEULaunchCardFooterMessage(forEULaunchDate date: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "d MMMM"

		let dateString = dateFormatter.string(from: date)

		return Localization.string(for: "holder.dashboard.qr.eulaunchcardfootermessage", comment: "", [dateString])
	}
}

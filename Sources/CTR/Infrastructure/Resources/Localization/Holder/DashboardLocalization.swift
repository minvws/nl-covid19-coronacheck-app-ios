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
				return L.holderDashboardNotValidInThisRegionScreenDomesticVaccinationTitle()
			case (.vaccination, .europeanUnion):
				return L.holderDashboardNotValidInThisRegionScreenEuVaccinationTitle()
			case (.test, .domestic):
				return L.holderDashboardNotValidInThisRegionScreenDomesticTestTitle()
			case (.test, .europeanUnion):
				return L.holderDashboardNotValidInThisRegionScreenEuTestTitle()
			case (.recovery, .domestic):
				return L.holderDashboardNotValidInThisRegionScreenDomesticRecoveryTitle()
			case (.recovery, .europeanUnion):
				return L.holderDashboardNotValidInThisRegionScreenEuRecoveryTitle()
		}
	}

	static func holderDashboardNotValidInThisRegionScreenMessage(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion) -> String {
		switch (originType, currentRegion) {
			case (.vaccination, .domestic):
				return L.holderDashboardNotValidInThisRegionScreenDomesticVaccinationMessage()
			case (.vaccination, .europeanUnion):
				return L.holderDashboardNotValidInThisRegionScreenEuVaccinationMessage()
			case (.test, .domestic):
				return L.holderDashboardNotValidInThisRegionScreenDomesticTestMessage()
			case (.test, .europeanUnion):
				return L.holderDashboardNotValidInThisRegionScreenEuTestMessage()
			case (.recovery, .domestic):
				return L.holderDashboardNotValidInThisRegionScreenDomesticRecoveryMessage()
			case (.recovery, .europeanUnion):
				return L.holderDashboardNotValidInThisRegionScreenEuRecoveryMessage()
		}
	}
}

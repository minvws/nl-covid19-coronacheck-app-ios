/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension String {

  static func holderDashboardQRExpired(originType: QRCodeOriginType, region: QRCodeValidityRegion) -> String {
	  switch (originType, region) {
		  case (.test, .domestic):
			  return L.holder_dashboard_originExpiredBanner_domesticTest_title()
		  case (.vaccination, .domestic):
			  return L.holder_dashboard_originExpiredBanner_domesticVaccine_title()
		  case (.recovery, .domestic):
			  return L.holder_dashboard_originExpiredBanner_domesticRecovery_title()
		  
		  case (.test, .europeanUnion):
			  return L.holder_dashboard_originExpiredBanner_internationalTest_title()
		  case (.vaccination, .europeanUnion):
			  return L.holder_dashboard_originExpiredBanner_internationalVaccine_title()
		  case (.recovery, .europeanUnion):
			  return L.holder_dashboard_originExpiredBanner_internationalRecovery_title()
		  
		  case (.vaccinationassessment, _):
			  return L.holder_dashboard_originExpiredBanner_visitorPass_title()
	  }
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
		  case (.vaccinationassessment, .domestic):
			  return L.holder_notvalidinthisregionmodal_visitorpass_international_title() // Should not happen
		  case (.vaccinationassessment, .europeanUnion):
			  return L.holder_notvalidinthisregionmodal_visitorpass_international_title()
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
		  case (.vaccinationassessment, .domestic):
			  return L.holder_notvalidinthisregionmodal_visitorpass_international_body() // Should not happen
		  case (.vaccinationassessment, .europeanUnion):
			  return L.holder_notvalidinthisregionmodal_visitorpass_international_body()
	  }
  }
}

/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol ForcedInformationFactory {
	
	var information: ForcedInformation { get }
}

struct HolderForcedInformationFactory: ForcedInformationFactory {
	
	var information: ForcedInformation {
		
		return .init(pages: [ForcedInformationPage(
			image: HolderForcedInformationFactory.isNL ? I.onboarding.tabbarNL() : I.onboarding.tabbarEN(),
			tagline: L.holderUpdatepageTagline(),
			title: L.holderUpdatepageTitleTab(),
			content: L.holderUpdatepageContentTab()
		)],
					 consent: nil,
					 version: 4)
	}
	
	private static var isNL: Bool {
		return "nl" == Locale.current.languageCode
	}
}

struct VerifierForcedInformationFactory: ForcedInformationFactory {
	
	var information: ForcedInformation {
		
		return .init(pages: [ForcedInformationPage(
			image: I.onboarding.tabbarNL(),
			tagline: L.new_in_app_subtitle(),
			title: L.new_in_app_risksetting_title(),
			content: L.new_in_app_risksetting_subtitle()
		)],
					 consent: nil,
					 // Disabled
					 version: 0)
	}
}

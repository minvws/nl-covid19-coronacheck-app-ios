/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

protocol NewFeaturesFactory {
	
	var information: NewFeatureInformation { get }
}

struct HolderNewFeaturesFactory: NewFeaturesFactory {
	
	var information: NewFeatureInformation {
		
		return .init(pages: [NewFeatureItem(
			image: HolderNewFeaturesFactory.isNL ? I.onboarding.tabbarNL() : I.onboarding.tabbarEN(),
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

struct VerifierNewFeaturesFactory: NewFeaturesFactory {
	
	var information: NewFeatureInformation {
		
		return .init(pages: [NewFeatureItem(
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

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
		
		return .init(
			pages: [NewFeatureItem(
				title: L.holderUpdatepageTitleTab(),
				content: L.holderUpdatepageContentTab(),
				image: HolderNewFeaturesFactory.isNL ? I.onboarding.tabbarNL() : I.onboarding.tabbarEN(),
				tagline: L.holderUpdatepageTagline(),
				step: 0
			)],
			version: 4
		)
	}
	
	private static var isNL: Bool {
		return "nl" == Locale.current.languageCode
	}
}

struct VerifierNewFeaturesFactory: NewFeaturesFactory {
	
	var information: NewFeatureInformation {
		
		return .init(
			pages: [NewFeatureItem(
				title: L.new_in_app_risksetting_title(),
				content: L.new_in_app_risksetting_subtitle(),
				image: I.onboarding.tabbarNL(),
				tagline: L.new_in_app_subtitle(),
				step: 0
			)],
			version: 0 // Disabled
		)
	}
}

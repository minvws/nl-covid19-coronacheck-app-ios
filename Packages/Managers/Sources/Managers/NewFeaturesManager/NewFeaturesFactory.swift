/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Shared
import Models
import Resources

public protocol NewFeaturesFactory {
	
	var information: NewFeatureInformation { get }
}

public struct HolderNewFeaturesFactory: NewFeaturesFactory {
	
	private var featureFlagManager: FeatureFlagManaging
	
	public init(featureFlagManager: FeatureFlagManaging) {
		
		self.featureFlagManager = featureFlagManager
	}
	
	public var information: NewFeatureInformation {
		
		if featureFlagManager.isInArchiveMode() {
			
			return NewFeatureInformation(
				pages: [PagedAnnoucementItem(
					title: L.holder_newintheapp_archiveMode_title(),
					content: L.holder_newintheapp_archiveMode_body(),
					image: I.newInTheApp.archiveMode(),
					imageBackgroundColor: C.white(),
					tagline: L.general_newintheapp(),
					step: 0
				)],
				version: 6
			)
		} else {
			return NewFeatureInformation(
				pages: [PagedAnnoucementItem(
					title: L.holder_newintheapp_foreignproofs_title(),
					content: L.holder_newintheapp_foreignproofs_body(),
					image: I.newInTheApp.paperDCC(),
					imageBackgroundColor: C.white(),
					tagline: L.general_newintheapp(),
					step: 0
				)],
				version: 5
			)
		}
	}
}

public struct VerifierNewFeaturesFactory: NewFeaturesFactory {
	
	public init() {}
	
	public var information: NewFeatureInformation {
		
		return .init(
			pages: [PagedAnnoucementItem(
				title: L.new_in_app_risksetting_title(),
				content: L.new_in_app_risksetting_subtitle(),
				image: I.onboarding.tabbarNL(),
				imageBackgroundColor: C.forcedInformationImage(),
				tagline: L.new_in_app_subtitle(),
				step: 0
			)],
			version: 0 // Disabled
		)
	}
}

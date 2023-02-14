/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Models

protocol FuzzyMatchingOnboardingFactoryProtocol {
	
	var pages: [PagedAnnoucementItem] { get }
}

struct FuzzyMatchingOnboardingFactory: FuzzyMatchingOnboardingFactoryProtocol {
	
	var pages: [PagedAnnoucementItem] {
		
		return [
			PagedAnnoucementItem(
				title: L.holder_fuzzyMatching_onboarding_firstPage_title(),
				content: L.holder_fuzzyMatching_onboarding_firstPage_body(),
				image: I.fuzzyOnboardingPage1(),
				step: 0
			),
			PagedAnnoucementItem(
				title: L.holder_fuzzyMatching_onboarding_secondPage_title(),
				content: L.holder_fuzzyMatching_onboarding_secondPage_body(),
				image: I.fuzzyOnboardingPage2(),
				step: 1
			),
			PagedAnnoucementItem(
				title: L.holder_fuzzyMatching_onboarding_thirdPage_title(),
				content: L.holder_fuzzyMatching_onboarding_thirdPage_body(),
				image: I.fuzzyOnboardingPage3(),
				step: 2,
				nextButtonTitle: L.holder_fuzzyMatching_onboarding_thirdPage_action()
			)
		]
	}
}

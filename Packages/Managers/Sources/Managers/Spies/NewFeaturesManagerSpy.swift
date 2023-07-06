/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models

public class NewFeaturesManagerSpy: NewFeaturesManaging {

	public init() {}
	
	public var invokedFactorySetter = false
	public var invokedFactorySetterCount = 0
	public var invokedFactory: NewFeaturesFactory?
	public var invokedFactoryList = [NewFeaturesFactory?]()
	public var invokedFactoryGetter = false
	public var invokedFactoryGetterCount = 0
	public var stubbedFactory: NewFeaturesFactory!

	public var factory: NewFeaturesFactory? {
		set {
			invokedFactorySetter = true
			invokedFactorySetterCount += 1
			invokedFactory = newValue
			invokedFactoryList.append(newValue)
		}
		get {
			invokedFactoryGetter = true
			invokedFactoryGetterCount += 1
			return stubbedFactory
		}
	}

	public var invokedNeedsUpdatingGetter = false
	public var invokedNeedsUpdatingGetterCount = 0
	public var stubbedNeedsUpdating: Bool! = false

	public var needsUpdating: Bool {
		invokedNeedsUpdatingGetter = true
		invokedNeedsUpdatingGetterCount += 1
		return stubbedNeedsUpdating
	}

	public var invokedPagedAnnouncementItems = false
	public var invokedPagedAnnouncementItemsCount = 0
	public var stubbedPagedAnnouncementItemsResult: [PagedAnnoucementItem]!

	public func pagedAnnouncementItems() -> [PagedAnnoucementItem]? {
		invokedPagedAnnouncementItems = true
		invokedPagedAnnouncementItemsCount += 1
		return stubbedPagedAnnouncementItemsResult
	}

	public var invokedUserHasViewedNewFeatureIntro = false
	public var invokedUserHasViewedNewFeatureIntroCount = 0

	public func userHasViewedNewFeatureIntro() {
		invokedUserHasViewedNewFeatureIntro = true
		invokedUserHasViewedNewFeatureIntroCount += 1
	}

	public var invokedWipePersistedData = false
	public var invokedWipePersistedDataCount = 0

	public func wipePersistedData() {
		invokedWipePersistedData = true
		invokedWipePersistedDataCount += 1
	}
}

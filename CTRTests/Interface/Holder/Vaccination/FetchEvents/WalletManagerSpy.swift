/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest

class WalletManagerSpy: WalletManaging {

	var invokedStoreEventGroup = false
	var invokedStoreEventGroupCount = 0
	var invokedStoreEventGroupParameters: (type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date)?
	var invokedStoreEventGroupParametersList = [(type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date)]()
	var stubbedStoreEventGroupResult: EventGroup!

	func storeEventGroup(_ type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date) -> EventGroup? {
		invokedStoreEventGroup = true
		invokedStoreEventGroupCount += 1
		invokedStoreEventGroupParameters = (type, providerIdentifier, signedResponse, issuedAt)
		invokedStoreEventGroupParametersList.append((type, providerIdentifier, signedResponse, issuedAt))
		return stubbedStoreEventGroupResult
	}

	var invokedRemoveExistingEventGroups = false
	var invokedRemoveExistingEventGroupsCount = 0
	var invokedRemoveExistingEventGroupsParameters: (type: EventType, providerIdentifier: String)?
	var invokedRemoveExistingEventGroupsParametersList = [(type: EventType, providerIdentifier: String)]()

	func removeExistingEventGroups(type: EventType, providerIdentifier: String) {
		invokedRemoveExistingEventGroups = true
		invokedRemoveExistingEventGroupsCount += 1
		invokedRemoveExistingEventGroupsParameters = (type, providerIdentifier)
		invokedRemoveExistingEventGroupsParametersList.append((type, providerIdentifier))
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest

class WalletManagerSpy: WalletManaging {

	required init(dataStoreManager: DataStoreManaging) {}

	var invokedStoreEventGroup = false
	var invokedStoreEventGroupCount = 0
	var invokedStoreEventGroupParameters: (type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date)?
	var invokedStoreEventGroupParametersList = [(type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date)]()
	var stubbedStoreEventGroupResult: Bool! = false

	func storeEventGroup(_ type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date) -> Bool {
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

	var invokedRemoveExistingGreenCards = false
	var invokedRemoveExistingGreenCardsCount = 0

	func removeExistingGreenCards() {
		invokedRemoveExistingGreenCards = true
		invokedRemoveExistingGreenCardsCount += 1
	}

	var invokedStoreDomesticGreenCard = false
	var invokedStoreDomesticGreenCardCount = 0
	var invokedStoreDomesticGreenCardParameters: (remoteGreenCard: RemoteGreenCards.DomesticGreenCard, Void)?
	var invokedStoreDomesticGreenCardParametersList = [(remoteGreenCard: RemoteGreenCards.DomesticGreenCard, Void)]()
	var stubbedStoreDomesticGreenCardResult: Bool! = false

	func storeDomesticGreenCard(_ remoteGreenCard: RemoteGreenCards.DomesticGreenCard) -> Bool {
		invokedStoreDomesticGreenCard = true
		invokedStoreDomesticGreenCardCount += 1
		invokedStoreDomesticGreenCardParameters = (remoteGreenCard, ())
		invokedStoreDomesticGreenCardParametersList.append((remoteGreenCard, ()))
		return stubbedStoreDomesticGreenCardResult
	}

	var invokedStoreEuGreenCard = false
	var invokedStoreEuGreenCardCount = 0
	var invokedStoreEuGreenCardParameters: (remoteEuGreenCard: RemoteGreenCards.EuGreenCard, Void)?
	var invokedStoreEuGreenCardParametersList = [(remoteEuGreenCard: RemoteGreenCards.EuGreenCard, Void)]()
	var stubbedStoreEuGreenCardResult: Bool! = false

	func storeEuGreenCard(_ remoteEuGreenCard: RemoteGreenCards.EuGreenCard) -> Bool {
		invokedStoreEuGreenCard = true
		invokedStoreEuGreenCardCount += 1
		invokedStoreEuGreenCardParameters = (remoteEuGreenCard, ())
		invokedStoreEuGreenCardParametersList.append((remoteEuGreenCard, ()))
		return stubbedStoreEuGreenCardResult
	}

	var invokedImportExistingTestCredential = false
	var invokedImportExistingTestCredentialCount = 0
	var invokedImportExistingTestCredentialParameters: (data: Data, sampleDate: Date)?
	var invokedImportExistingTestCredentialParametersList = [(data: Data, sampleDate: Date)]()
	var stubbedImportExistingTestCredentialResult: Bool! = false

	func importExistingTestCredential(_ data: Data, sampleDate: Date) -> Bool {
		invokedImportExistingTestCredential = true
		invokedImportExistingTestCredentialCount += 1
		invokedImportExistingTestCredentialParameters = (data, sampleDate)
		invokedImportExistingTestCredentialParametersList.append((data, sampleDate))
		return stubbedImportExistingTestCredentialResult
	}
}

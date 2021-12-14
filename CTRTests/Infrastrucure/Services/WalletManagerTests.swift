/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR
import XCTest
import Nimble

class WalletManagerTests: XCTestCase {

	private var sut: WalletManager!
	private var dataStoreManager: DataStoreManaging!

	override func setUp() {

		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory)
		sut = WalletManager(dataStoreManager: dataStoreManager)
	}

	func test_initializer() {

		// Given
		var wallet: Wallet?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// When
			wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context)
		}

		// Then
		expect(wallet).toEventuallyNot(beNil())
		expect(wallet?.label).toEventually(equal(WalletManager.walletName))
	}

	func test_initializer_withExistingWallet() {

		// Given
		var wallet: Wallet?
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// Delete the one created by the initializer in the setup()
			for element in WalletModel.listAll(managedContext: context) {
				context.delete(element)
			}
			let exitingWallet = WalletModel.create(label: WalletManager.walletName, managedContext: context)

			// When
			sut = WalletManager(dataStoreManager: dataStoreManager)
			wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context)

			// Then
			expect(wallet) == exitingWallet
		}
		expect(wallet).toEventuallyNot(beNil())
	}

	func test_storeEventGroup() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())

		// When
		let result = sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)

		// Then
		expect(result) == true
		expect(wallet?.eventGroups).to(haveCount(1))
	}

	func test_removeExistingEventGroups_withProviderIdentifier() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		sut.removeExistingEventGroups(type: .vaccination, providerIdentifier: "CoronaCheck")

		// Then
		expect(wallet?.eventGroups).to(beEmpty())
	}

	func test_removeExistingEventGroups_otherProviderIdentifier() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "Other Provider",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		sut.removeExistingEventGroups(type: .vaccination, providerIdentifier: "CoronaCheck")

		// Then
		expect(wallet?.eventGroups).to(haveCount(1))
	}

	func test_removeExistingEventGroups_otherType() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		sut.removeExistingEventGroups(type: .vaccination, providerIdentifier: "CoronaCheck")

		// Then
		expect(wallet?.eventGroups).to(haveCount(1))
	}

	func test_removeAllEventGroups() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.test,
			providerIdentifier: "Other Provider",
			jsonData: Data(),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GGD",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		sut.removeExistingEventGroups()

		// Then
		expect(wallet?.eventGroups).to(haveCount(0))
	}

	func test_listEventGroups() {

		// Given
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data(),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.test,
			providerIdentifier: "Other Provider",
			jsonData: Data(),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GGD",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		let list = sut.listEventGroups()

		// Then
		expect(list).to(haveCount(3))
	}

	func test_fetchSignedEvents_noEvents() {

		// Given

		// When
		let signedEvents = sut.fetchSignedEvents()

		// Then
		expect(signedEvents).to(beEmpty())
	}

	func test_fetchSignedEvents_oneEvent() {

		// Given
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data("test".utf8),
			issuedAt: Date()
		)

		// When
		let signedEvents = sut.fetchSignedEvents()

		// Then
		expect(signedEvents).toNot(beEmpty())
		expect(signedEvents).to(contain("test"))
	}

	func test_fetchSignedEvents_twoEvents() {

		// Given
		sut.storeEventGroup(
			.test,
			providerIdentifier: "CoronaCheck",
			jsonData: Data("test".utf8),
			issuedAt: Date()
		)
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			jsonData: Data("vaccination".utf8),
			issuedAt: Date()
		)

		// When
		let signedEvents = sut.fetchSignedEvents()

		// Then
		expect(signedEvents).toNot(beEmpty())
		expect(signedEvents).to(contain("test"))
		expect(signedEvents).to(contain("vaccination"))
	}

	func test_hasEventGroup_vaccination() {

		// Given
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "GGD",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		let hasEventGroup = sut.hasEventGroup(type: "vaccination", providerIdentifier: "GGD")

		// Then
		expect(hasEventGroup) == true
	}

	func test_hasEventGroup_recovery() {

		// Given
		sut.storeEventGroup(
			.recovery,
			providerIdentifier: "DCC",
			jsonData: Data(),
			issuedAt: Date()
		)

		// When
		let hasEventGroup = sut.hasEventGroup(type: "recovery", providerIdentifier: EventFlow.paperproofIdentier)

		// Then
		expect(hasEventGroup) == true
	}
}

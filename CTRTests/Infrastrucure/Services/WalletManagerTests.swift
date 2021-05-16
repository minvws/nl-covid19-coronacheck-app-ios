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
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// When
			let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context)

			// Then
			expect(wallet).toNot(beNil())
			expect(wallet?.label) == WalletManager.walletName
		}
	}

	func test_initializer_withExitingWallet() {

		// Given
		dataStoreManager = DataStoreManager(.inMemory)
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			let exitingWallet = WalletModel.create(label: WalletManager.walletName, managedContext: context)

			// When
			sut = WalletManager(dataStoreManager: dataStoreManager)
			let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context)

			// Then
			expect(wallet) == exitingWallet
		}
	}

	func test_storeEventGroup() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())

		// When
		let eventGroup = sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			signedResponse: SignedResponse(payload: "test", signature: "signature"),
			issuedAt: Date()
		)

		// Then
		expect(eventGroup).toNot(beNil())

		expect(wallet?.eventGroups).to(haveCount(1))
		if case let walletEventGroup as EventGroup = wallet?.eventGroups?.allObjects.first {
			expect(walletEventGroup) == eventGroup
		} else {
			fail("Event does not match")
		}
	}

	func test_removeExistingEventGroups() {

		// Given
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		sut.storeEventGroup(
			.vaccination,
			providerIdentifier: "CoronaCheck",
			signedResponse: SignedResponse(payload: "test", signature: "signature"),
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
			signedResponse: SignedResponse(payload: "test", signature: "signature"),
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
			signedResponse: SignedResponse(payload: "test", signature: "signature"),
			issuedAt: Date()
		)

		// When
		sut.removeExistingEventGroups(type: .vaccination, providerIdentifier: "CoronaCheck")

		// Then
		expect(wallet?.eventGroups).to(haveCount(1))
	}
}

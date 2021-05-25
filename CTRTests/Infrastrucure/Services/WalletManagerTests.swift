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
			signedResponse: SignedResponse(payload: "test", signature: "signature"),
			issuedAt: Date()
		)

		// Then
		expect(result) == true
		expect(wallet?.eventGroups).to(haveCount(1))
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

	func test_import() {

		// Given
		var result = false

		// When
		result = sut.importExistingTestCredential(Data(), sampleDate: Date())

		// Then
		let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: dataStoreManager.managedObjectContext())
		expect(wallet?.greenCards?.allObjects).toEventually(haveCount(1))
		expect((wallet?.greenCards?.allObjects.first as? GreenCard)?.credentials?.allObjects).toEventually(haveCount(1))
		expect((wallet?.greenCards?.allObjects.first as? GreenCard)?.origins?.allObjects).toEventually(haveCount(1))
		expect(result).toEventually(beTrue())
	}
}

/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
@testable import CTR

// swiftlint:disable:next type_name
class HolderDashboardRemovedEventsDatasourceTests: XCTestCase {
	
	var sut: HolderDashboardRemovedEventsDatasource!
	var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		
		environmentSpies = setupEnvironmentSpies()
	}
	
	func test_existingBlockedEvents_arriveInCallback() throws {
		
		// Arrange
 		let context = environmentSpies.dataStoreManager.managedObjectContext()
		var blockedEvent: RemovedEvent?
		
		context.performAndWait {
			
			blockedEvent = RemovedEventModel.create(
				type: EventMode.vaccination,
				eventDate: now,
				reason: RemovalReason.blockedEvent.rawValue,
				wallet: WalletModel.createTestWallet(managedContext: context)!,
				managedContext: context
			)
		}

		// Act
		sut = HolderDashboardRemovedEventsDatasource(reason: RemovalReason.blockedEvent)

		var didUpdateResult: [RemovedEventItem]?
		sut.didUpdate = { blockedEventItem in
			didUpdateResult = blockedEventItem
		}
 
		// Assert
		expect(didUpdateResult).to(haveCount(1))
		expect(didUpdateResult?.first?.reason) == RemovalReason.blockedEvent.rawValue
		expect(didUpdateResult?.first?.eventDate) == now
		expect(didUpdateResult?.first?.type) == .vaccination
	}
	
	func test_existingRemovedEvents_shouldNotArriveInCallback() throws {
		
		// Arrange
		let context = environmentSpies.dataStoreManager.managedObjectContext()
		var blockedEvent: RemovedEvent?
		
		context.performAndWait {
			
			blockedEvent = RemovedEventModel.create(
				type: EventMode.vaccination,
				eventDate: now,
				reason: RemovalReason.mismatchedIdentity.rawValue,
				wallet: WalletModel.createTestWallet(managedContext: context)!,
				managedContext: context
			)
		}

		// Act
		sut = HolderDashboardRemovedEventsDatasource(reason: RemovalReason.blockedEvent)

		var didUpdateResult: [RemovedEventItem]?
		sut.didUpdate = { blockedEventItem in
			didUpdateResult = blockedEventItem
		}
 
		// Assert
		expect(didUpdateResult).to(haveCount(0))
	}
	
	func test_nonexistingBlockedEvents_arriveInCallback() throws {
		
		// Arrange
		sut = HolderDashboardRemovedEventsDatasource(reason: RemovalReason.blockedEvent)
		
		var didUpdateResult: [RemovedEventItem]?
		sut.didUpdate = { blockedEventItem in
			didUpdateResult = blockedEventItem
		}

		// Act
		let context = environmentSpies.dataStoreManager.managedObjectContext()
		var blockedEvent: RemovedEvent?
		
		context.performAndWait {
			
			blockedEvent = RemovedEventModel.create(
				type: EventMode.vaccination,
				eventDate: now,
				reason: RemovalReason.blockedEvent.rawValue,
				wallet: WalletModel.createTestWallet(managedContext: context)!,
				managedContext: context
			)
		}
 
		// Assert
		expect(blockedEvent) != nil
		expect(didUpdateResult).toEventually(haveCount(1))
		expect(didUpdateResult?.first?.reason).toEventually(equal(RemovalReason.blockedEvent.rawValue))
		expect(didUpdateResult?.first?.eventDate).toEventually(equal(now))
		expect(didUpdateResult?.first?.type).toEventually(equal(.vaccination))
	}
}

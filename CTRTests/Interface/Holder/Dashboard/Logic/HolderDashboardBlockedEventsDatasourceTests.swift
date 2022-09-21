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
class HolderDashboardBlockedEventsDatasourceTests: XCTestCase {
	
	var sut: HolderDashboardBlockedEventsDatasource!
	var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		
		environmentSpies = setupEnvironmentSpies()
	}
	
	func test_existingBlockedEvents_arriveInCallback() throws {
		
		// Arrange
 		let context = environmentSpies.dataStoreManager.managedObjectContext()
		var blockedEvent: BlockedEvent?
		
		context.performAndWait {
			
			blockedEvent = BlockedEventModel.create(
				type: EventMode.vaccination,
				eventDate: now,
				reason: "The reason",
				wallet: WalletModel.createTestWallet(managedContext: context)!,
				managedContext: context
			)
		}

		// Act
		sut = HolderDashboardBlockedEventsDatasource()

		var didUpdateResult: [BlockedEventItem]?
		sut.didUpdate = { blockedEventItem in
			didUpdateResult = blockedEventItem
		}
 
		// Assert
		expect(didUpdateResult).to(haveCount(1))
		expect(didUpdateResult?.first?.reason) == "The reason"
		expect(didUpdateResult?.first?.eventDate) == now
		expect(didUpdateResult?.first?.type) == .vaccination
	}
	
	func test_nonexistingBlockedEvents_arriveInCallback() throws {
		
		// Arrange
		sut = HolderDashboardBlockedEventsDatasource()
		
		var didUpdateResult: [BlockedEventItem]?
		sut.didUpdate = { blockedEventItem in
			didUpdateResult = blockedEventItem
		}

		// Act
		let context = environmentSpies.dataStoreManager.managedObjectContext()
		var blockedEvent: BlockedEvent?
		
		context.performAndWait {
			
			blockedEvent = BlockedEventModel.create(
				type: EventMode.vaccination,
				eventDate: now,
				reason: "The reason",
				wallet: WalletModel.createTestWallet(managedContext: context)!,
				managedContext: context
			)
		}
 
		// Assert
		expect(didUpdateResult).toEventually(haveCount(1))
		expect(didUpdateResult?.first?.reason).toEventually(equal("The reason"))
		expect(didUpdateResult?.first?.eventDate).toEventually(equal(now))
		expect(didUpdateResult?.first?.type).toEventually(equal(.vaccination))
	}
}

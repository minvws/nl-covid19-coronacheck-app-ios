/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import Persistence
import CoreData
import TestingShared

extension WalletModel {
	
	@discardableResult class func createTestWallet(managedContext: NSManagedObjectContext) -> Wallet? {
		
		return Wallet(label: "testWallet", managedContext: managedContext)
	}
}

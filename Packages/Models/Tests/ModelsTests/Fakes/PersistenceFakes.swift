//
//  File.swift
//  
//
//  Created by Ian Dundas on 14/02/2023.
//

import Foundation
@testable import Persistence
import CoreData
import TestingShared

extension WalletModel {
	
	@discardableResult class func createTestWallet(managedContext: NSManagedObjectContext) -> Wallet? {
		
		return Wallet(label: "testWallet", managedContext: managedContext)
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

protocol WalletManaging {

	/// Store an event group
	/// - Parameters:
	///   - type: the event type (vaccination, recovery, test)
	///   - providerIdentifier: the identifier of the provider
	///   - signedResponse: the json of the signed response to store
	///   - issuedAt: when was this event administered?
	/// - Returns: True if stored
	func storeEventGroup(_ type: EventType, providerIdentifier: String, signedResponse: SignedResponse, issuedAt: Date) -> Bool

	/// Remove any existing event groups for the type and provider identifier
	/// - Parameters:
	///   - type: the type of event group
	///   - providerIdentifier: the identifier of the the provider
	func removeExistingEventGroups(type: EventType, providerIdentifier: String)
}

class WalletManager: WalletManaging, Logging {

	static let walletName = "main"

	private var dataStoreManager: DataStoreManaging

	init( dataStoreManager: DataStoreManaging = Services.dataStoreManager) {

		self.dataStoreManager = dataStoreManager

		createMainWalletIfNotExists()
	}

	private func createMainWalletIfNotExists() {

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if WalletModel.findBy(label: WalletManager.walletName, managedContext: context) == nil {
				WalletModel.create(label: WalletManager.walletName, managedContext: context)
				dataStoreManager.save(context)
			}
		}
	}

	/// Store an event group
	/// - Parameters:
	///   - type: the event type (vaccination, recovery, test)
	///   - providerIdentifier: the identifier of the provider
	///   - signedResponse: the json of the signed response to store
	///   - issuedAt: when was this event administered?
	/// - Returns: optional event group
	@discardableResult func storeEventGroup(
		_ type: EventType,
		providerIdentifier: String,
		signedResponse: SignedResponse,
		issuedAt: Date) -> Bool {

		var success = true

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
			   let jsonData = try? JSONEncoder().encode(signedResponse) {
				EventGroupModel.create(
					type: type,
					providerIdentifier: providerIdentifier,
					maxIssuedAt: issuedAt,
					jsonData: jsonData,
					wallet: wallet,
					managedContext: context
				)
				dataStoreManager.save(context)
			} else {
				success = false
			}
		}
		return success
	}

	/// Remove any existing event groups for the type and provider identifier
	/// - Parameters:
	///   - type: the type of event group
	///   - providerIdentifier: the identifier of the the provider
	func removeExistingEventGroups(type: EventType, providerIdentifier: String) {

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let eventGroups = wallet.eventGroups {
					for case let eventGroup as EventGroup in eventGroups.allObjects {
						if eventGroup.providerIdentifier == providerIdentifier && eventGroup.type == type.rawValue && type == .vaccination {
							self.logDebug("Removing eventGroup \(String(describing: eventGroup.providerIdentifier)) \(String(describing: eventGroup.type))")
							context.delete(eventGroup)
						}
					}
					dataStoreManager.save(context)
				}
			}
		}
	}
}
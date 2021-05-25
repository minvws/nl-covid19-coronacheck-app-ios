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

	func removeExistingGreenCards()

	func storeDomesticGreenCard(_ remoteGreenCard: RemoteGreenCards.DomesticGreenCard) -> Bool

	func storeEuGreenCard(_ remoteEuGreenCard: RemoteGreenCards.EuGreenCard) -> Bool

	init( dataStoreManager: DataStoreManaging)

	/// Import any existing version 1 credentials into the database
	/// - Parameters:
	///   - data: the credential data
	///   - sampleDate: the sample date of the credential
	/// - Returns: True if import was successful
	func importExistingTestCredential(_ data: Data, sampleDate: Date) -> Bool
}

class WalletManager: WalletManaging, Logging {

	static let walletName = "main"

	private var dataStoreManager: DataStoreManaging

	required init( dataStoreManager: DataStoreManaging = Services.dataStoreManager) {

		self.dataStoreManager = dataStoreManager

		createMainWalletIfNotExists()
	}

	private func createMainWalletIfNotExists() {

		let context = dataStoreManager.backgroundContext()
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

		let context = dataStoreManager.backgroundContext()
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

		let context = dataStoreManager.backgroundContext()
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

	func removeExistingGreenCards() {

		let context = dataStoreManager.backgroundContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCrards = wallet.greenCards {
					for case let greenCard as GreenCard in greenCrards.allObjects {

						context.delete(greenCard)
					}
				}
				dataStoreManager.save(context)
			}
		}
	}

	func storeDomesticGreenCard(_ remoteDomesticGreenCard: RemoteGreenCards.DomesticGreenCard) -> Bool {

		if remoteDomesticGreenCard.origins.isEmpty {
			return false
		}

		var result = true
		let context = dataStoreManager.backgroundContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCard = GreenCardModel.create(type: .domestic, wallet: wallet, managedContext: context) {

					for remoteOrigin in remoteDomesticGreenCard.origins {

						result = result && storeOrigin(remoteOrigin: remoteOrigin, greenCard: greenCard, context: context)

					}
					if let ccm = remoteDomesticGreenCard.createCredentialMessages, let data = Data(base64Encoded: ccm) {
						// data, version and date should come from the CreateCredential method of the Go Library.
						result = result && CredentialModel.create(data: data, validFrom: Date(), version: 2, greenCard: greenCard, managedContext: context) != nil
					}
					dataStoreManager.save(context)
				}
			} else {
				result = false
			}
		}
		return result
	}

	func storeEuGreenCard(_ remoteEuGreenCard: RemoteGreenCards.EuGreenCard) -> Bool {

		var result = true
		let context = dataStoreManager.backgroundContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {
				if let greenCard = GreenCardModel.create(type: .eu, wallet: wallet, managedContext: context) {

					for remoteOrigin in remoteEuGreenCard.origins {

						result = result && storeOrigin(remoteOrigin: remoteOrigin, greenCard: greenCard, context: context)
					}

					// data, version and date should come from the CreateCredential method of the Go Library.
					let data = Data(remoteEuGreenCard.credential.utf8)
					result = result && CredentialModel.create(data: data, validFrom: Date(), version: 2, greenCard: greenCard, managedContext: context) != nil
					dataStoreManager.save(context)
				} else {
					result = false
				}
			}
		}
		return result
	}

	private func storeOrigin(remoteOrigin: RemoteGreenCards.Origin, greenCard: GreenCard, context: NSManagedObjectContext) -> Bool {

		if let type = OriginType(rawValue: remoteOrigin.type) {

			return OriginModel.create(type: type, eventDate: remoteOrigin.eventTime, expireDate: remoteOrigin.expirationTime, greenCard: greenCard, managedContext: context) != nil
		} else {
			return false
		}
	}

	func listGreenCards() -> [GreenCard] {

		var result = [GreenCard]()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
			   let greenCards = wallet.greenCards?.allObjects as? [GreenCard] {
				result = greenCards
			}
		}
		return result
	}

	/// Import any existing version 1 credentials into the database
	/// - Parameters:
	///   - data: the credential data
	///   - sampleDate: the sample date of the credential
	/// - Returns: True if import was successful
	func importExistingTestCredential(_ data: Data, sampleDate: Date) -> Bool {

		guard let expireDate = Calendar.current.date(byAdding: .hour, value: 40, to: sampleDate) else {

			return false
		}

		var result = true
		let context = dataStoreManager.backgroundContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				guard let greenCards = wallet.greenCards, greenCards.allObjects.isEmpty else {
					// Existing greencard.
					result = false
					return
				}

				if let greenCard = GreenCardModel.create(type: .domestic, wallet: wallet, managedContext: context) {
					result = result && OriginModel.create(type: .negativeTest, eventDate: sampleDate, expireDate: expireDate, greenCard: greenCard, managedContext: context) != nil
					// Legacy credential should have version 1
					result = result && CredentialModel.create(data: data, validFrom: sampleDate, version: 1, greenCard: greenCard, managedContext: context) != nil
					dataStoreManager.save(context)
				}
			} else {
				result = false
			}
		}
		return result
	}
}

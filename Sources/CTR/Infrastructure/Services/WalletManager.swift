/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

protocol WalletManaging: AnyObject {

	/// Store an event group
	/// - Parameters:
	///   - type: the event type (vaccination, recovery, test)
	///   - providerIdentifier: the identifier of the provider
	///   - jsonData: the json  data of the original signed event or dcc
	///   - expiryDate: when will this eventgroup expire?
	/// - Returns: True if stored
	func storeEventGroup(
		_ type: EventMode,
		providerIdentifier: String,
		jsonData: Data,
		expiryDate: Date?) -> Bool

	func fetchSignedEvents() -> [String]

	/// Remove any existing event groups for the type and provider identifier
	/// - Parameters:
	///   - type: the type of event group
	///   - providerIdentifier: the identifier of the the provider
	func removeExistingEventGroups(type: EventMode, providerIdentifier: String)

	/// Remove any existing event groups
	func removeExistingEventGroups()

	func removeExistingGreenCards()

	func storeDomesticGreenCard(_ remoteGreenCard: RemoteGreenCards.DomesticGreenCard, cryptoManager: CryptoManaging) -> Bool

	func storeEuGreenCard(_ remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging) -> Bool

	/// List all the event groups
	/// - Returns: all the event groups
	func listEventGroups() -> [EventGroup]

	func listGreenCards() -> [GreenCard]

	func removeExpiredGreenCards(forDate: Date) -> [(greencardType: String, originType: String)]

	/// Expire event groups that are no longer valid
	/// - Parameter forDate: Current date
	func expireEventGroups(forDate: Date)
	
	func removeEventGroup(_ objectID: NSManagedObjectID) -> Result<Void, Error>

	/// Return all greencards for current wallet which still have unexpired origins (regardless of credentials):
	func greencardsWithUnexpiredOrigins(now: Date, ofOriginType: OriginType?) -> [GreenCard]
	
	func updateEventGroup(identifier: String, expiryDate: Date)
}

class WalletManager: WalletManaging {

	static let walletName = "main"

	private var dataStoreManager: DataStoreManaging

	required init( dataStoreManager: DataStoreManaging) {
		
		self.dataStoreManager = dataStoreManager

		guard AppFlavor.flavor == .holder else { return }
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
	///   - expiryDate: when will this eventgroup expire?
	/// - Returns: optional event group
	@discardableResult func storeEventGroup(
		_ type: EventMode,
		providerIdentifier: String,
		jsonData: Data,
		expiryDate: Date?) -> Bool {

		var success = true

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else {
				success = false
				return
			}
			
			EventGroupModel.create(
				type: type,
				providerIdentifier: providerIdentifier,
				expiryDate: expiryDate,
				jsonData: jsonData,
				wallet: wallet,
				managedContext: context
			)
			dataStoreManager.save(context)
		}
		return success
	}
	
	/// Expire event groups that are no longer valid
	/// - Parameter forDate: Current date
	func expireEventGroups(forDate: Date) {
		
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() {
				if let expiryDate = eventGroup.expiryDate, expiryDate < forDate {
					logInfo("Sashay away \(String(describing: eventGroup.providerIdentifier)) \(String(describing: eventGroup.type)) \(String(describing: eventGroup.expiryDate))")
					context.delete(eventGroup)
				}
			}
		}
	}
	
	func removeEventGroup(_ objectID: NSManagedObjectID) -> Result<Void, Error> {
		
		dataStoreManager.delete(objectID)
	}

	func fetchSignedEvents() -> [String] {

		var signedEvents = [String]()

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() {
				if let jsonString = eventGroup.getSignedEvents() {
					signedEvents.append(jsonString)
				}
			}
		}
		return signedEvents
	}

	/// Remove any existing event groups for the type and provider identifier
	/// - Parameters:
	///   - type: the type of event group
	///   - providerIdentifier: the identifier of the the provider
	func removeExistingEventGroups(type: EventMode, providerIdentifier: String) {
		
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() where eventGroup.providerIdentifier?.lowercased() == providerIdentifier.lowercased() && eventGroup.type == type.rawValue {
				logDebug("Removing eventGroup \(String(describing: eventGroup.providerIdentifier)) \(String(describing: eventGroup.type))")
				context.delete(eventGroup)
			}
			dataStoreManager.save(context)
		}
	}

	/// Remove any existing event groups
	func removeExistingEventGroups() {
		
		let context = dataStoreManager.managedObjectContext()
		
		context.performAndWait {
			
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			for eventGroup in wallet.castEventGroups() {
				logDebug("Removing eventGroup \(String(describing: eventGroup.providerIdentifier)) \(String(describing: eventGroup.type))")
				context.delete(eventGroup)
			}
			dataStoreManager.save(context)
		}
	}

	func removeExistingGreenCards() {

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCards = wallet.greenCards {
					for case let greenCard as GreenCard in greenCards.allObjects {

						greenCard.delete(context: context)
					}
					dataStoreManager.save(context)
				}
			}
		}
	}

	/// Remove expired GreenCards that contain no more valid origins
	/// returns: an array of `Greencard.type` Strings. One for each GreenCard that was deleted.
	@discardableResult func removeExpiredGreenCards(forDate: Date) -> [(greencardType: String, originType: String)] {
		var deletedGreenCardTypes: [(greencardType: String, originType: String)] = []

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCards = wallet.greenCards {
					for case let greenCard as GreenCard in greenCards.allObjects {

						guard let origins = greenCard.castOrigins() else {
							greenCard.delete(context: context)
							break
						}

						// Does the GreenCard have any valid Origins remaining?
						let hasValidOrFutureOrigins = origins
							.contains(where: { ($0.expirationTime ?? .distantPast) > forDate })

						if hasValidOrFutureOrigins {
							continue
						} else {
							let lastExpiredOrigin = origins.sorted(by: { ($0.expirationTime ?? .distantPast) < ($1.expirationTime ?? .distantPast) }).last

							if let greencardType = greenCard.type, let originType = lastExpiredOrigin?.type {
								deletedGreenCardTypes += [(greencardType: greencardType, originType: originType)]
							}
							greenCard.delete(context: context)
						}
					}
				}
				dataStoreManager.save(context)
			}
		}

		return deletedGreenCardTypes
	}

	func storeDomesticGreenCard(_ remoteDomesticGreenCard: RemoteGreenCards.DomesticGreenCard, cryptoManager: CryptoManaging) -> Bool {

		if remoteDomesticGreenCard.origins.isEmpty {
			return false
		}

		var result = true
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCard = GreenCardModel.create(type: .domestic, wallet: wallet, managedContext: context) {

					for remoteOrigin in remoteDomesticGreenCard.origins {
						result = result && storeOrigin(remoteOrigin: remoteOrigin, greenCard: greenCard, context: context)
					}
					if let ccm = remoteDomesticGreenCard.createCredentialMessages, let data = Data(base64Encoded: ccm) {
						switch convertToDomesticCredentials(cryptoManager: cryptoManager, data: data) {
							case .failure:
								result = false
							case let .success(domesticCredentials):
								for domesticCredential in domesticCredentials {
									result = result && storeDomesticCredential(domesticCredential, greenCard: greenCard, context: context)
								}
						}
					}
				}
			} else {
				result = false
			}
			if result {
				dataStoreManager.save(context)
			}
		}
		return result
	}

	/// Store a credential in CoreData from a Domestic Credential
	/// - Parameters:
	///   - domesticCredential: the domestic credential
	///   - greenCard: the green card
	///   - context: the managed object context
	/// - Returns: True if storing was successful
	private func storeDomesticCredential(_ domesticCredential: DomesticCredential, greenCard: GreenCard, context: NSManagedObjectContext) -> Bool {

		var result = true

		if let version = Int32(domesticCredential.attributes.credentialVersion),
		   let validFromTimeInterval = TimeInterval(domesticCredential.attributes.validFrom),
		   let validHoursInt = Int( domesticCredential.attributes.validForHours),
		   let data = domesticCredential.credential {

			let validFromDate = Date(timeIntervalSince1970: validFromTimeInterval)
			if let expireDate = Calendar.current.date(byAdding: .hour, value: validHoursInt, to: validFromDate) {

				result = result && CredentialModel.create(
					data: data,
					validFrom: validFromDate,
					expirationTime: expireDate,
					version: version,
					greenCard: greenCard,
					managedContext: context) != nil
			}
		}
		return result
	}

	private func convertToDomesticCredentials(cryptoManager: CryptoManaging, data: Data) -> Result<[DomesticCredential], Error> {

		let createCredentialResult = cryptoManager.createCredential(data)
		switch createCredentialResult {
			case let .success(credentials):
				do {
					let objects = try JSONDecoder().decode([DomesticCredential].self, from: credentials)
					logVerbose("object: \(objects)")
					return .success(objects)
				} catch {
					logError("Error Deserializing: \(error)")
					return .failure(error)
				}
			case let .failure(error):
				return .failure(error)
		}
	}

	func storeEuGreenCard(_ remoteEuGreenCard: RemoteGreenCards.EuGreenCard, cryptoManager: CryptoManaging) -> Bool {

		var result = true
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {
				if let greenCard = GreenCardModel.create(type: .eu, wallet: wallet, managedContext: context) {
					// Origins
					for remoteOrigin in remoteEuGreenCard.origins {
						result = result && storeOrigin(remoteOrigin: remoteOrigin, greenCard: greenCard, context: context)
					}
					// Credential (DCC has 1 credential)
					let data = Data(remoteEuGreenCard.credential.utf8)
					if let euCredentialAttributes = cryptoManager.readEuCredentials(data) {
						result = result && CredentialModel.create(
							data: data,
							validFrom: Date(timeIntervalSince1970: 0), // DCC are always immediately valid
							expirationTime: Date(timeIntervalSince1970: euCredentialAttributes.expirationTime),
							version: Int32(euCredentialAttributes.credentialVersion),
							greenCard: greenCard,
							managedContext: context) != nil
					} else {
						result = false
					}
				} else {
					result = false
				}
			}
			if result {
				dataStoreManager.save(context)
			}
		}
		return result
	}

	private func storeOrigin(remoteOrigin: RemoteGreenCards.Origin, greenCard: GreenCard, context: NSManagedObjectContext) -> Bool {

		if let type = OriginType(rawValue: remoteOrigin.type) {

			return OriginModel.create(
				type: type,
				eventDate: remoteOrigin.eventTime,
				expirationTime: remoteOrigin.expirationTime,
				validFromDate: remoteOrigin.validFrom,
				doseNumber: remoteOrigin.doseNumber,
				greenCard: greenCard,
				managedContext: context
			) != nil

		} else {
			return false
		}
	}

	func listGreenCards() -> [GreenCard] {

		var result = [GreenCard]()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
			   let greenCards = wallet.castGreenCards() {
				result = greenCards
			}
		}
		return result
	}

	/// List all the event groups
	/// - Returns: all the event groups
	func listEventGroups() -> [EventGroup] {

		var result = [EventGroup]()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
			
			result = wallet.castEventGroups()
		}
		return result
	}

	/// Return all greencards for current wallet which still have unexpired origins (regardless of credentials):
	func greencardsWithUnexpiredOrigins(now: Date, ofOriginType originType: OriginType? = nil) -> [GreenCard] {
		var result = [GreenCard]()

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
				  let allGreenCards = wallet.castGreenCards()
			else { return }

			for greenCard in allGreenCards {
				guard let origins = greenCard.castOrigins() else { break }

				let hasValidRemainingOrigins = origins.contains(where: { origin in
					guard let expirationTime = origin.expirationTime,
						  expirationTime > now
					else { return false }

					// Optional extra check:
					if let originType = originType {
						return origin.type == originType.rawValue
					}

					return true
				})

				if hasValidRemainingOrigins {
					result += [greenCard]
				}
			}
		}

		return result
	}
	
	func updateEventGroup(identifier: String, expiryDate: Date) {
		
		logDebug("WalletManager: Should update eventGroup \(identifier) with expiry \(expiryDate)")
		
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) else { return }
		
			wallet.castEventGroups().forEach { eventGroup in
				if String(eventGroup.autoId) == identifier {
					eventGroup.expiryDate = expiryDate
				}
			}
			dataStoreManager.save(context)
		}
	}
}

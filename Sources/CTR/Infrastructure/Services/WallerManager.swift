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

	func storeDomesticGreenCard(_ remoteGreenCard: RemoteGreenCards.DomesticGreenCard, cryptoManager: CryptoManaging) -> Bool

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
						if eventGroup.providerIdentifier == providerIdentifier && eventGroup.type == type.rawValue {
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

	/// Remove expired GreenCards that contain no more valid origins
	/// returns: an array of `Greencard.type` Strings. One for each GreenCard that was deleted.
	func removeExpiredGreenCards() -> [String] {

		var deletedGreenCardTypes: [String] = []

		let context = dataStoreManager.backgroundContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCards = wallet.greenCards {
					for case let greenCard as GreenCard in greenCards.allObjects {

						// Does the GreenCard have any valid Origins remaining?
						let validOrFutureOrigins = greenCard.origins?
							.compactMap { $0 as? Origin }
							.contains(where: { (origin: Origin) in
								(origin.expirationTime ?? .distantPast) > Date()
							}) ?? false

						if !validOrFutureOrigins {
							if let type = greenCard.type {
								deletedGreenCardTypes += [type]
							}
							context.delete(greenCard)
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
		let context = dataStoreManager.backgroundContext()
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
									result = result && storeCredential(domesticCredential: domesticCredential, greenCard: greenCard, context: context)
								}
						}
					}
					dataStoreManager.save(context)
				}
			} else {
				result = false
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
	private func storeCredential(domesticCredential: DomesticCredential, greenCard: GreenCard, context: NSManagedObjectContext) -> Bool {

		var result = true

		if let credentialVersion = domesticCredential.attributes.credentialVersion,
		   let version = Int32(credentialVersion),
		   let validFrom = domesticCredential.attributes.validFrom,
		   let validFromTimeInterval = TimeInterval(validFrom),
		   let validHours = domesticCredential.attributes.validForHours,
		   let validHoursInt = Int(validHours),
		   let data = domesticCredential.credential {

			let validFromDate = Date(timeIntervalSince1970: validFromTimeInterval)
			if let expireDate = Calendar.current.date(byAdding: .hour, value: validHoursInt, to: validFromDate) {

//				logDebug("Added credential from \(validFromDate) to \(expireDate)")
//				logDebug("data: \(data.map { String(format: "%02x", $0) }.joined())")

				result = result && CredentialModel.create(
					data: data,
					validFrom: validFromDate,
					expirationTime: expireDate,
					version: version,
					greenCard: greenCard,
					managedContext: context) != nil
			}
//			let check = cryptoManager.readDomesticCredentials(data)
//			logDebug("check: \(check)")
		}
		return result
	}

	private func convertToDomesticCredentials(cryptoManager: CryptoManaging, data: Data) -> Result<[DomesticCredential], Error> {

		let createCredentialResult = cryptoManager.createCredential(data)
		switch createCredentialResult {
			case let .success(credentials):
				do {
					let objects = try JSONDecoder().decode([DomesticCredential].self, from: credentials)
					logDebug("object: \(objects)")
					return .success(objects)
				} catch {
					self.logError("Error Deserializing: \(error)")
					return .failure(error)
				}
			case let .failure(error):
				return .failure(error)
		}
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
					if let expireDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) {
						result = result && CredentialModel.create(data: data, validFrom: Date(), expirationTime: expireDate, version: 2, greenCard: greenCard, managedContext: context) != nil
					}
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

			return OriginModel.create(
				type: type,
				eventDate: remoteOrigin.eventTime,
				expirationTime: remoteOrigin.expirationTime,
				validFromDate: remoteOrigin.validFrom,
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
					result = result && OriginModel.create(
						type: .negativeTest,
						eventDate: sampleDate,
						expirationTime: expireDate,
						validFromDate: sampleDate, // I guess this is correct?
						greenCard: greenCard,
						managedContext: context) != nil
					// Legacy credential should have version 1
					result = result && CredentialModel.create(
						data: data,
						validFrom: sampleDate,
						expirationTime: expireDate,
						version: 1,
						greenCard: greenCard,
						managedContext: context) != nil
					dataStoreManager.save(context)
				}
			} else {
				result = false
			}
		}
		return result
	}
}

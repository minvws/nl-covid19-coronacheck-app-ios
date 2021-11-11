/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
	///   - issuedAt: when was this event administered?
	/// - Returns: True if stored
	func storeEventGroup(_ type: EventMode, providerIdentifier: String, jsonData: Data, issuedAt: Date) -> Bool

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

	init( dataStoreManager: DataStoreManaging)

	/// List all the event groups
	/// - Returns: all the event groups
	func listEventGroups() -> [EventGroup]

	func listGreenCards() -> [GreenCard]

	func listOrigins(type: OriginType) -> [Origin]

	func removeExpiredGreenCards() -> [(greencardType: String, originType: String)]

	/// Expire event groups that are no longer valid
	/// - Parameters:
	///   - vaccinationValidity: the max validity for vaccination
	///   - recoveryValidity: the max validity for recovery
	///   - testValidity: the max validity for test
	func expireEventGroups(vaccinationValidity: Int?, recoveryValidity: Int?, testValidity: Int?)

	/// Return all greencards for current wallet which still have unexpired origins (regardless of credentials):
	func greencardsWithUnexpiredOrigins(now: Date, ofOriginType: OriginType?) -> [GreenCard]

	func canSkipMultiDCCUpgrade() -> Bool
	
	func shouldShowMultiDCCUpgradeBanner(userSettings: UserSettingsProtocol) -> Bool
}

class WalletManager: WalletManaging, Logging {

	static let walletName = "main"

	private var dataStoreManager: DataStoreManaging

	required init( dataStoreManager: DataStoreManaging = Services.dataStoreManager) {

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
		_ type: EventMode,
		providerIdentifier: String,
		jsonData: Data,
		issuedAt: Date) -> Bool {

		var success = true

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {
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

	/// Expire event groups that are no longer valid
	/// - Parameters:
	///   - vaccinationValidity: the max validity for vaccination (in hours)
	///   - recoveryValidity: the max validity for recovery (in hours)
	///   - testValidity: the max validity for test (in hours)
	func expireEventGroups(vaccinationValidity: Int?, recoveryValidity: Int?, testValidity: Int?) {

		if let maxValidity = vaccinationValidity {
			findAndExpireEventGroups(for: .vaccination, maxValidity: maxValidity)
		}

		if let maxValidity = recoveryValidity {
			findAndExpireEventGroups(for: .recovery, maxValidity: maxValidity)
		}

		if let maxValidity = testValidity {
			findAndExpireEventGroups(for: .test, maxValidity: maxValidity)
		}
	}

	/// Find event groups that exceed their validity and remove them from the database
	/// - Parameters:
	///   - type: the type of event group (vaccination, test, recovery)
	///   - maxValidity: the max validity (in HOURS) of the event group beyond the max issued at date. (from remote config)
	private func findAndExpireEventGroups(for type: EventMode, maxValidity: Int) {

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {
			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
			   let eventGroups = wallet.eventGroups {
				for case let eventGroup as EventGroup in eventGroups.allObjects where eventGroup.type == type.rawValue {
					if let maxIssuedAt = eventGroup.maxIssuedAt,
					   let expireDate = Calendar.current.date(byAdding: .hour, value: maxValidity, to: maxIssuedAt) {
						if expireDate > Date() {
							logDebug("Shantay, you stay \(String(describing: eventGroup.providerIdentifier)) \(type) \(String(describing: eventGroup.maxIssuedAt))")
						} else {
							logDebug("Sashay away \(String(describing: eventGroup.providerIdentifier)) \(type) \(String(describing: eventGroup.maxIssuedAt))")
							context.delete(eventGroup)
						}
					}
				}
				dataStoreManager.save(context)
			}
		}
	}

	func fetchSignedEvents() -> [String] {

		var result = [String]()

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {
				if let eventGroups = wallet.eventGroups {
					for case let eventGroup as EventGroup in eventGroups.allObjects {

						if let data = eventGroup.jsonData,
						   let convertedToString = String(data: data, encoding: .utf8) {
							result.append(convertedToString.replacingOccurrences(of: "\\/", with: "/"))
						}
					}
				}
			}
		}
		return result
	}

	/// Remove any existing event groups for the type and provider identifier
	/// - Parameters:
	///   - type: the type of event group
	///   - providerIdentifier: the identifier of the the provider
	func removeExistingEventGroups(type: EventMode, providerIdentifier: String) {

		let context = dataStoreManager.managedObjectContext()
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

	/// Remove any existing event groups
	func removeExistingEventGroups() {

		let context = dataStoreManager.managedObjectContext()

		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let eventGroups = wallet.eventGroups {
					for case let eventGroup as EventGroup in eventGroups.allObjects {
						self.logDebug("Removing eventGroup \(String(describing: eventGroup.providerIdentifier)) \(String(describing: eventGroup.type))")
						context.delete(eventGroup)
					}
					dataStoreManager.save(context)
				}
			}
		}
	}

	func removeExistingGreenCards() {

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCards = wallet.greenCards {
					for case let greenCard as GreenCard in greenCards.allObjects {

						context.delete(greenCard)
					}
				}
				dataStoreManager.save(context)
			}
		}
	}

	/// Remove expired GreenCards that contain no more valid origins
	/// returns: an array of `Greencard.type` Strings. One for each GreenCard that was deleted.
	@discardableResult func removeExpiredGreenCards() -> [(greencardType: String, originType: String)] {
		var deletedGreenCardTypes: [(greencardType: String, originType: String)] = []

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {

				if let greenCards = wallet.greenCards {
					for case let greenCard as GreenCard in greenCards.allObjects {

						guard let origins = greenCard.origins?.compactMap({ $0 as? Origin }) else {
							context.delete(greenCard)
							break
						}

						// Does the GreenCard have any valid Origins remaining?
						let hasValidOrFutureOrigins = origins
							.contains(where: { ($0.expirationTime ?? .distantPast) > Date() })

						if hasValidOrFutureOrigins {
							break
						} else {
							let lastExpiredOrigin = origins.sorted(by: { ($0.expirationTime ?? .distantPast) < ($1.expirationTime ?? .distantPast) }).last

							if let greencardType = greenCard.type, let originType = lastExpiredOrigin?.type {
								deletedGreenCardTypes += [(greencardType: greencardType, originType: originType)]
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
					self.logError("Error Deserializing: \(error)")
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

					for remoteOrigin in remoteEuGreenCard.origins {

						result = result && storeOrigin(remoteOrigin: remoteOrigin, greenCard: greenCard, context: context)
					}

					let data = Data(remoteEuGreenCard.credential.utf8)
					if let euCredentialAttributes = cryptoManager.readEuCredentials(data) {
						logVerbose("euCredentialAttributes: \(euCredentialAttributes)")
						result = result && CredentialModel.create(
							data: data,
							validFrom: Date(timeIntervalSince1970: euCredentialAttributes.issuedAt),
							expirationTime: Date(timeIntervalSince1970: euCredentialAttributes.expirationTime),
							version: Int32(euCredentialAttributes.credentialVersion),
							greenCard: greenCard,
							managedContext: context) != nil
						dataStoreManager.save(context)
					}

					// data, version and date should come from the CreateCredential method of the Go Library.
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

	/// List all the event groups
	/// - Returns: all the event groups
	func listEventGroups() -> [EventGroup] {

		var result = [EventGroup]()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
			   let eventGroups = wallet.eventGroups?.allObjects as? [EventGroup] {
				result = eventGroups
			}
		}
		return result
	}

	/// List all the origins for a type (across greenCards)
	/// - Parameter type: the type or origin ( vaccination, test, recovery)
	/// - Returns: array of origins. (no specific order)
	func listOrigins(type: OriginType) -> [Origin] {

		var result = [Origin]()

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			if let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context) {
				guard let greenCards = wallet.greenCards?.allObjects as? [GreenCard] else {
					return
				}
				for greenCard in greenCards {

					if let origins = greenCard.origins?.allObjects as? [Origin] {
						result.append(contentsOf: origins.filter { $0.type == type.rawValue })
					}
				}
			}
		}
		return result
	}

	/// Return all greencards for current wallet which still have unexpired origins (regardless of credentials):
	func greencardsWithUnexpiredOrigins(now: Date, ofOriginType originType: OriginType? = nil) -> [GreenCard] {
		var result = [GreenCard]()

		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context),
				  let allGreenCards = wallet.greenCards?.allObjects as? [GreenCard]
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

	/// Calculates whether the device can skip the MultiDCC migration
	/// (either because no greencards available yet, or because there's
	/// only a HKVI event)
	func canSkipMultiDCCUpgrade() -> Bool {

		guard !listGreenCards().isEmpty else {
			// no greencards so can skip migration for now:
			return false
		}

		// Check if we should show the banner.
		let vaccinationEventGroups = listEventGroups().filter { $0.type == "vaccination" }
		let hkviVaccinationEvents = vaccinationEventGroups.filter { $0.providerIdentifier?.uppercased() == "DCC" }

		let regularVaccinationEvents: [EventFlow.Event] = vaccinationEventGroups
			.filter({ $0.providerIdentifier?.uppercased() != "DCC" })
			.flatMap({ vaccineEventGroup -> [EventFlow.Event] in

				// convert back to a network response and get the payload:
				guard let jsonData = vaccineEventGroup.jsonData,
					let payloadJSON = try? JSONDecoder().decode(SignedResponse.self, from: jsonData).decodedPayload,

					// gives a list of remote vaccination events
					let eventResultWrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: payloadJSON),
					let events = eventResultWrapper.events
				else {
					return []
				}

				return events
			})
			//	Deduplicate vaccine events based on date:
			.reduce([EventFlow.Event]()) { pile, next in
				guard let nextDateString = next.vaccination?.dateString else { return pile }

				if pile
					.compactMap({ $0.vaccination?.dateString })
					.contains(where: { $0 == nextDateString }) {
						// do nothing
						return pile
					} else {
						return pile + [next]
					}
			}

		// If we only have a single event (e.g. hkvi) we'll never get more cards so the upgrade can be skipped.
		return (hkviVaccinationEvents.count + regularVaccinationEvents.count) <= 1
	}

	func shouldShowMultiDCCUpgradeBanner(userSettings: UserSettingsProtocol) -> Bool {
		guard !listGreenCards().isEmpty else {
			// no greencards so user still needs to load them:
			return false
		}
		guard !userSettings.didCompleteEUVaccinationMigration else {
			// do nothing
			return false
		}
		guard !canSkipMultiDCCUpgrade() else {
			// do nothing
			return false
		}

		let allEUVaccinationGreencards = listGreenCards()
			.filter { $0.getType() == .eu }
			.filter { greencard in
				guard let origins = greencard.castOrigins() else { return false }
				return !origins.filter({ $0.type == "vaccination" }).isEmpty
			}

		// if there are more than 1 vaccination events but 1 or less greencards,
		// show the banner to offer people an upgrade
		return allEUVaccinationGreencards.count == 1 // show the banner
	}
}

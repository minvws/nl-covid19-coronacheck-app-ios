/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData
import Transport

class EventGroupModel {

//	@discardableResult class func create(
//		type: EventMode,
//		providerIdentifier: String,
//		expiryDate: Date?,
//		jsonData: Data,
//		wallet: Wallet,
//		managedContext: NSManagedObjectContext) -> EventGroup? {
//
//		let object = EventGroup(context: managedContext)
//		object.type = type.rawValue
//		object.providerIdentifier = providerIdentifier
//		object.expiryDate = expiryDate
//		object.jsonData = jsonData
//		object.wallet = wallet
//
//		return object
//	}
	
	@discardableResult class func findBy(
		wallet: Wallet,
		type: EventMode,
		providerIdentifier: String,
		jsonData: Data) -> EventGroup? {
			
		return wallet.castEventGroups()
			.filter { $0.type == type.rawValue }
			.filter { $0.providerIdentifier == providerIdentifier }
			.filter { $0.jsonData == jsonData }
			.last
		}
}

extension EventGroup {
	
	@discardableResult convenience init(
		type: EventMode,
		providerIdentifier: String,
		expiryDate: Date?,
		jsonData: Data,
		wallet: Wallet,
		managedContext: NSManagedObjectContext) {

		self.init(context: managedContext)
		self.type = type.rawValue
		self.providerIdentifier = providerIdentifier
		self.expiryDate = expiryDate
		self.jsonData = jsonData
		self.wallet = wallet
	}
	
	func getSignedEvents() -> String? {
		
		guard let slashedJSONData = jsonData,
			  let removedSlashesJSONString = String(data: slashedJSONData, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/"),
			  let fixedJSONData = removedSlashesJSONString.data(using: .utf8) else {
			return nil }
		
		guard var dictionary = try? JSONDecoder().decode([String: String].self, from: fixedJSONData) else {
			return nil }
		
		dictionary["id"] = uniqueIdentifier
		
		guard let reencodedData = try? JSONEncoder().encode(dictionary),
			  let finalJSONString = String(data: reencodedData, encoding: .utf8) else {
			return nil }
		
		return finalJSONString
	}
	
}

extension EventGroup {
	public var uniqueIdentifier: String {
		objectID.uriRepresentation().relativePath
	}
}

extension Array where Element == RemoteGreenCards.BlobExpiry {
	
	/// Determine which BlobExpiry elements ("blockItems") match EventGroups which were sent to be signed:
	func combinedWith(matchingEventGroups eventGroups: [EventGroup]) -> [(RemoteGreenCards.BlobExpiry, EventGroup)] {
		reduce([]) { partialResult, blockItem in
			guard let matchingEvent = eventGroups.first(where: { "\($0.uniqueIdentifier)" == blockItem.identifier }) else { return partialResult }
			return partialResult + [(blockItem, matchingEvent)]
		}
	}
}

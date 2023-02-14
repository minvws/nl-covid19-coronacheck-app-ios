/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import CoreData

extension EventGroup {
	
	public func getSignedEvents() -> String? {
		
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
	
	@discardableResult public convenience init(
		rawType: String,
		providerIdentifier: String,
		expiryDate: Date?,
		jsonData: Data,
		wallet: Wallet,
		isDraft: Bool,
		managedContext: NSManagedObjectContext) {
			
			self.init(context: managedContext)
			self.type = rawType
			self.providerIdentifier = providerIdentifier
			self.expiryDate = expiryDate
			self.jsonData = jsonData
			self.wallet = wallet
			self.isDraft = isDraft
		}
}

extension EventGroup {
	public var uniqueIdentifier: String {
		objectID.uriRepresentation().relativePath
	}
}

extension EventGroup {
	
	@discardableResult public convenience init(
		type: EventMode,
		providerIdentifier: String,
		expiryDate: Date?,
		jsonData: Data,
		wallet: Wallet,
		isDraft: Bool,
		managedContext: NSManagedObjectContext) {
			
			self.init(context: managedContext)
			self.type = type.rawValue
			self.providerIdentifier = providerIdentifier
			self.expiryDate = expiryDate
			self.jsonData = jsonData
			self.wallet = wallet
			self.isDraft = isDraft
		}
}

class EventGroupModel {
	
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

public enum EventMode: Equatable {
	
	public enum TestRoute: Equatable {
		// We scanned a paper proof negative test
		case dcc
		// We want to fetch a negative test from the GGD
		case ggd
		// We want to fetch a negative test with a token from a commercial provider
		case commercial
	}
	
	case paperflow
	case vaccinationAndPositiveTest
	case recovery
	case test(TestRoute)
	case vaccination
	case vaccinationassessment
 
	public var rawValue: String {
		switch self {
			case .paperflow:
				return "paperflow"
			case .vaccinationAndPositiveTest:
				return "positiveTest" // rawValue positiveTest for backwards compatibility with CoreData
			case .recovery:
				return "recovery"
			case .test:
				return "test"
			case .vaccination:
				return "vaccination"
			case .vaccinationassessment:
				return "vaccinationassessment"
		}
	}
	
	public var asList: [String]? {
		switch self {
			case .vaccinationAndPositiveTest: return ["vaccination", "positivetest"]
			case .test: return ["negativetest"]
			case .vaccination: return ["vaccination"]
			case .recovery: return ["positivetest"]
			case .vaccinationassessment: return ["vaccinationassessment"]
			case .paperflow: return nil
		}
	}
}

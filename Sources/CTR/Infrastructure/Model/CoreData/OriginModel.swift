/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

enum OriginType: String, Codable, Equatable {

	case recovery
	case test
	case vaccination
	case vaccinationassessment
	
	var localized: String {
		switch self {
			case .recovery: return L.general_positiveTest()
			case .vaccination: return L.general_vaccination()
			case .test: return L.general_negativeTest()
			case .vaccinationassessment: return L.general_visitorPass()
		}
	}
	
	/// e.g. "Test Certificate", "Vaccination Certificate"
	var localizedProof: String {
		switch self {
			case .recovery: return L.general_recoverycertificate()
			case .vaccination: return L.general_vaccinationcertificate()
			case .test: return L.general_testcertificate()
			case .vaccinationassessment: return L.general_visitorPass()
		}
	}
	
	/// e.g. Vaccinatiedatum etc.
	var localizedDateLabel: String? {
		switch self {
			case .recovery: return L.generalRecoverydate()
			case .vaccination: return L.generalVaccinationdate()
			case .test: return L.generalTestdate()
			case .vaccinationassessment: return nil // not localized.
		}
	}
	
	/// e.g. "Internationaal vaccinatiebewijs"
	var localizedProofInternational0G: String {
		switch self {
			case .recovery: return L.general_recoverycertificate_0G()
			case .vaccination: return L.general_vaccinationcertificate_0G()
			case .test: return L.general_testcertificate_0G()
			case .vaccinationassessment: return localizedProof
		}
	}

	/// There is a particular order to sort these onscreen
	var customSortIndex: Double {
		switch self {
			case .vaccination: return 0
			case .recovery: return 1
			case .vaccinationassessment: return 2
			case .test: return 3
		}
	}
}

class OriginModel {

	static let entityName = "Origin"

	@discardableResult class func create(
		type: OriginType,
		eventDate: Date,
		expirationTime: Date,
		validFromDate: Date,
		doseNumber: Int?,
		greenCard: GreenCard,
		managedContext: NSManagedObjectContext) -> Origin? {

		guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedContext) as? Origin else {
			return nil
		}

		object.type = type.rawValue
		object.eventDate = eventDate
		object.expirationTime = expirationTime
		object.validFromDate = validFromDate
		if let doseNumber {
			object.doseNumber = doseNumber as NSNumber
		}
		object.greenCard = greenCard

		return object
	}
}

extension Array {

	/// Find the Origin element with the latest expiry date (note: this could still be in the past).
	func latestOriginExpiryTime() -> Date? where Element == Origin {
		sorted(by: { ($0.expirationTime ?? .distantPast) < ($1.expirationTime ?? .distantPast) })
			.last?
			.expirationTime
	}
}

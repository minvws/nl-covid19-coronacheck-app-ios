/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData
import Shared

extension Origin {
	
	@discardableResult public convenience init(
		type: OriginType,
		eventDate: Date,
		expirationTime: Date,
		validFromDate: Date,
		doseNumber: Int?,
		greenCard: GreenCard,
		managedContext: NSManagedObjectContext) {
			
			self.init(context: managedContext)
			self.type = type.rawValue
			self.eventDate = eventDate
			self.expirationTime = expirationTime
			self.validFromDate = validFromDate
			if let doseNumber = doseNumber {
				self.doseNumber = doseNumber as NSNumber
			}
			self.greenCard = greenCard
		}
	
	/// Get the hints, strongly typed.
	public func castHints() -> [OriginHint] {
		
		return hints?.compactMap({ $0 as? OriginHint }) ?? []
	}
	
	/// Is this a paper based dcc?
	/// - Returns: True if this is a paper based dcc
	public func isPaperBasedDCC() -> Bool {
		
		for hint in castHints() where hint.hint == "event_from_dcc" {
			return true
		}
		return false
	}
}

public enum OriginType: String, Codable, Equatable {
	
	case recovery
	case test
	case vaccination
}

extension Array {

	/// Find the Origin element with the latest expiry date (note: this could still be in the past).
	public func latestOriginExpiryTime() -> Date? where Element == Origin {
		sorted(by: { ($0.expirationTime ?? .distantPast) < ($1.expirationTime ?? .distantPast) })
			.last?
			.expirationTime
	}
	
	/// Is there an origin that is paper based dcc?
	public func hasPaperBasedDCC() -> Bool where Element == Origin {
		
		filter { $0.isPaperBasedDCC() }.isNotEmpty
	}
}

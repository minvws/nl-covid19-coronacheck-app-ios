/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Transport

protocol IdentityCheckerProtocol {

	/// Check if the identities in event groups and remote events match
	/// - Parameters:
	///   - eventGroups: the event groups
	///   - remoteEvents: the remote events
	/// - Returns: True if they match, False if they do not match
	func compare(eventGroups: [EventGroup], with remoteEvents: [RemoteEvent]) -> Bool
}

class IdentityChecker: IdentityCheckerProtocol {
	
	/// Check if the identities in event groups and remote events match
	/// - Parameters:
	///   - eventGroups: the event groups
	///   - remoteEvents: the remote events
	/// - Returns: True if they match, False if they do not match
	func compare(eventGroups: [EventGroup], with remoteEvents: [RemoteEvent]) -> Bool {

		var match = true
		let existingIdentities: [EventFlow.Identity] = convertEventGroupsToIdentities(eventGroups)
		let remoteIdentities: [EventFlow.Identity] = convertRemoteEventsToIdentities(remoteEvents)

		for existingIdentity in existingIdentities {
			for remoteIdentity in remoteIdentities {
				// US 4973: Only check if the date of birth is equal
				match = match
				&& remoteIdentity.getBirthDay() == existingIdentity.getBirthDay()
				&& remoteIdentity.getBirthMonth() == existingIdentity.getBirthMonth()
//				&& remoteIdentity.getBirthYear() == existingIdentity.getBirthYear()
			}
		}
		if !match {
			logDebug("Does the identity of the new events match with the existing ones? \(match)")
		}
		return match
	}

	private func convertEventGroupsToIdentities(_ eventGroups: [EventGroup]) -> [EventFlow.Identity] {

		var identities = [EventFlow.Identity]()

		for storedEvent in eventGroups {
			if let jsonData = storedEvent.jsonData {
				if let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
				   let decodedPayloadData = Data(base64Encoded: object.payload),
				   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData),
				   let identity = wrapper.identity {
						identities.append(identity)
				} else if let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData) {
					if let credentialData = object.credential.data(using: .utf8),
					   let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData) {
						identities.append(euCredentialAttributes.identity)
					}
				}
			}
		}
		return identities
	}

	private func convertRemoteEventsToIdentities(_ remoteEvents: [RemoteEvent]) -> [EventFlow.Identity] {

		return remoteEvents.compactMap {
			return $0.wrapper.identity
		}
	}
}

extension EventFlow.Identity {

	public func getBirthDay() -> String? {

		guard let birthDate = birthDateString.flatMap(Formatter.getDateFrom) else {
			return nil
		}
		let components = Calendar.current.dateComponents([.day], from: birthDate)
		if let dayInt = components.day {
			return "\(dayInt)"
		}
		return nil
	}

	public func getBirthMonth() -> String? {

		guard let birthDate = birthDateString.flatMap(Formatter.getDateFrom) else {
			return nil
		}
		let components = Calendar.current.dateComponents([.month], from: birthDate)
		if let monthInt = components.month {
			return "\(monthInt)"
		}
		return nil
	}
	
	public func getBirthYear() -> String? {

		guard let birthDate = birthDateString.flatMap(Formatter.getDateFrom) else {
			return nil
		}
		let components = Calendar.current.dateComponents([.year], from: birthDate)
		if let yearInt = components.year {
			return "\(yearInt)"
		}
		return nil
	}
}

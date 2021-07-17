/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol IdentityCheckerProtocol {

	/// Check if the identities in event groups and remote events match
	/// - Parameters:
	///   - eventGroups: the event groups
	///   - remoteEvents: the remote events
	/// - Returns: True if they match, False if they do not match
	func compare(eventGroups: [EventGroup], with remoteEvents: [RemoteEvent]) -> Bool
}

class IdentityChecker: IdentityCheckerProtocol, Logging {

	/// Check if the identities in event groups and remote events match
	/// - Parameters:
	///   - eventGroups: the event groups
	///   - remoteEvents: the remote events
	/// - Returns: True if they match, False if they do not match
	func compare(eventGroups: [EventGroup], with remoteEvents: [RemoteEvent]) -> Bool {

		var match = true
		let existingIdentities: [Any] = convertEventGroupsToIdentities(eventGroups)
		let remoteIdentities: [Any] = convertRemoteEventsToIdentities(remoteEvents)

		for existingIdentity in existingIdentities {

			var existingTuple: IdentityTuple?

			if let existing = existingIdentity as? EventFlow.Identity {
				existingTuple = existing.identityMatchTuple()
			} else if let existing = existingIdentity as? TestHolderIdentity {
				existingTuple = existing.identityMatchTuple()
			}
			logDebug("existingIdentity: \(String(describing: existingTuple))")

			for remoteIdentity in remoteIdentities {

				var remoteTuple: IdentityTuple?

				if let remote = remoteIdentity as? EventFlow.Identity {
					remoteTuple = remote.identityMatchTuple()
				} else if let remote = remoteIdentity as? TestHolderIdentity {
					remoteTuple = remote.identityMatchTuple()
				}
				logDebug("existingIdentity: \(String(describing: remoteTuple))")

				match = match && (remoteTuple?.day == existingTuple?.day && remoteTuple?.month == existingTuple?.month &&
									(remoteTuple?.firstNameInitial == existingTuple?.firstNameInitial ||
										remoteTuple?.lastNameInitial == remoteTuple?.lastNameInitial)
				)
			}
		}
		logDebug("Does the identity of the new events match with the existing ones? \(match)")
		return match
	}

	private func convertEventGroupsToIdentities(_ eventGroups: [EventGroup]) -> [Any] {

		var identities = [Any]()

		for storedEvent in eventGroups {
			if let jsonData = storedEvent.jsonData,
			   let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
			   let decodedPayloadData = Data(base64Encoded: object.payload),
			   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData) {

				if let identity = wrapper.identity {
					identities.append(identity)
				} else if let holder = wrapper.result?.holder {
					identities.append(holder)
				}
			}
		}
		return identities
	}

	private func convertRemoteEventsToIdentities(_ remoteEvents: [RemoteEvent]) -> [Any] {

		return remoteEvents.compactMap {
			if let identity = $0.wrapper.identity {
				return identity
			} else if let holder = $0.wrapper.result?.holder {
				return holder
			}
			return nil
		}
	}
}

typealias IdentityTuple = (firstNameInitial: String?, lastNameInitial: String?, day: String?, month: String?)

extension EventFlow.Identity {

	func identityMatchTuple() -> IdentityTuple {

		var firstNameInitial: String?
		var lastNameInitial: String?
		var day: String?
		var month: String?

		if let firstName = firstName {
			let firstChar = firstName.prefix(1)
			firstNameInitial = String(firstChar).uppercased()
		}

		if let lastName = lastName {
			let firstChar = lastName.prefix(1)
			lastNameInitial = String(firstChar).uppercased()
		}

		if let birthDate = birthDateString.flatMap(Formatter.getDateFrom) {
			let components = Calendar.current.dateComponents([.month, .day], from: birthDate)
			if let dayInt = components.day {
				day = "\(dayInt)"
			}
			if let monthInt = components.month {
				month = "\(monthInt)"
			}
		}
		return (firstNameInitial: firstNameInitial, lastNameInitial: lastNameInitial, day: day, month: month)
	}
}

extension TestHolderIdentity {

	func identityMatchTuple() -> IdentityTuple {

		return (firstNameInitial: firstNameInitial, lastNameInitial: lastNameInitial, day: birthDay, month: birthMonth)
	}
}

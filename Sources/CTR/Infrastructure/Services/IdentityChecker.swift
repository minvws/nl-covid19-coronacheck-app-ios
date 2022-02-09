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
				existingTuple = existing.asIdentityTuple()
			} else if let existing = existingIdentity as? TestHolderIdentity {
				existingTuple = existing.asIdentityTuple()
			}
			logVerbose("existingIdentity: \(String(describing: existingTuple))")

			for remoteIdentity in remoteIdentities {

				var remoteTuple: IdentityTuple?

				if let remote = remoteIdentity as? EventFlow.Identity {
					remoteTuple = remote.asIdentityTuple()
				} else if let remote = remoteIdentity as? TestHolderIdentity {
					remoteTuple = remote.asIdentityTuple()
				}
				logVerbose("remoteIdentity: \(String(describing: remoteTuple))")

				match = match &&
					remoteTuple?.day == existingTuple?.day &&
					remoteTuple?.month == existingTuple?.month &&
					(isInitialEqual(remoteTuple?.firstNameInitial, existingTuple?.firstNameInitial) ||
						isInitialEqual(remoteTuple?.lastNameInitial, existingTuple?.lastNameInitial))
			}
		}
		if !match {
			logDebug("Does the identity of the new events match with the existing ones? \(match)")
		}
		return match
	}

	private func isInitialEqual(_ lhs: String?, _ rhs: String?) -> Bool {

		switch (lhs, rhs) {
			case (nil, _), (_, nil):
				return true
			default:
				return lhs == rhs
		}
	}

	private func convertEventGroupsToIdentities(_ eventGroups: [EventGroup]) -> [Any] {

		var identities = [Any]()

		for storedEvent in eventGroups {
			if let jsonData = storedEvent.jsonData {
				if let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
				   let decodedPayloadData = Data(base64Encoded: object.payload),
				   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData) {

					if let identity = wrapper.identity {
						identities.append(identity)
					} else if let holder = wrapper.result?.holder {
						identities.append(holder)
					}
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

	func asIdentityTuple() -> IdentityTuple {

		return (
			firstNameInitial: getFirstNameInitIal(),
			lastNameInitial: getLastNameInitial(),
			day: getBirthDay(),
			month:  getBirthMonth()
		)
	}

	private func getFirstNameInitIal() -> String? {

		return Normalizer.toAzInitial(firstName)?.uppercased()
	}

	private func getLastNameInitial() -> String? {

		return Normalizer.toAzInitial(lastName)?.uppercased()
	}

	private func getBirthDay() -> String? {

		guard let birthDate = birthDateString.flatMap(Formatter.getDateFrom) else {
			return nil
		}
		let components = Calendar.current.dateComponents([.day], from: birthDate)
		if let dayInt = components.day {
			return "\(dayInt)"
		}
		return nil
	}

	private func getBirthMonth() -> String? {

		guard let birthDate = birthDateString.flatMap(Formatter.getDateFrom) else {
			return nil
		}
		let components = Calendar.current.dateComponents([.month], from: birthDate)
		if let monthInt = components.month {
			return "\(monthInt)"
		}
		return nil
	}
}

class Normalizer {

	static let permittedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz ")
	static let initialsCharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	static let filterCharacterSet = CharacterSet(charactersIn: "-' ")

	/// Normalize any input, transform to latin, remove all diacritics
	/// - Parameter input: the unnormalized input
	/// - Returns: normalized output
	class func normalize(_ input: String) -> String? {

		if let latinInput = input.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
			let permittedInput = String(latinInput.unicodeScalars.filter { permittedCharacterSet.contains($0) })
			return permittedInput
		}
		return nil
	}

	/// Return the initial of the input, only if is in A-Z
	/// - Parameter input: the string to check
	/// - Returns: optional the initial
	class func toAzInitial(_ input: String?) -> String? {

		guard let input = input, !input.isEmpty else {
			return nil
		}

		let validInput = String(input.unicodeScalars.filter { !filterCharacterSet.contains($0) })
		let firstChar = validInput.prefix(1)
		let capitalizedInitial = String(firstChar).uppercased()
		guard capitalizedInitial.unicodeScalars.allSatisfy({ initialsCharacterSet.contains($0) }) else {

			return nil
		}
		return capitalizedInitial
	}
}

extension TestHolderIdentity {

	func asIdentityTuple() -> IdentityTuple {

		return (firstNameInitial: firstNameInitial.uppercased(), lastNameInitial: lastNameInitial.uppercased(), day: birthDay, month: birthMonth)
	}
}

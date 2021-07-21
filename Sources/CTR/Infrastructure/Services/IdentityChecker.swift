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

	let cryptoManager: CryptoManaging

	required init(cryptoManager: CryptoManaging = Services.cryptoManager) {

		self.cryptoManager = cryptoManager
	}

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

				match = match && (remoteTuple?.day == existingTuple?.day && remoteTuple?.month == existingTuple?.month)
				// Disable the name checking for now.
//					&&
//									(remoteTuple?.firstNameInitial == existingTuple?.firstNameInitial ||
//										remoteTuple?.lastNameInitial == remoteTuple?.lastNameInitial)
//				)
			}
		}
		logDebug("Does the identity of the new events match with the existing ones? \(match)")
		return match
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
					if let identity = object.identity(cryptoManager: cryptoManager) {
						identities.append(identity)
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

		guard let firstName = firstName else {
			return nil
		}
		let normalized = Normalizer.normalize(firstName)
		let firstChar = normalized.prefix(1)
		return String(firstChar).uppercased()
	}

	private func getLastNameInitial() -> String? {

		guard let lastName = lastName else {
			return nil
		}
		let normalized = Normalizer.normalize(lastName)
		let firstChar = normalized.prefix(1)
		return String(firstChar).uppercased()
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

	/// Normalize any input, transform to latin, remove all diacritics
	/// - Parameter input: the unnormalized input
	/// - Returns: normalized output
	class func normalize(_ input: String) -> String {

		if let latinInput = input.applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower;"), reverse: false) {
			let permittedInput = String(latinInput.unicodeScalars.filter { permittedCharacterSet.contains($0) })
			return permittedInput
		}
		return input
	}
}

extension TestHolderIdentity {

	func asIdentityTuple() -> IdentityTuple {

		return (firstNameInitial: firstNameInitial, lastNameInitial: lastNameInitial, day: birthDay, month: birthMonth)
	}
}

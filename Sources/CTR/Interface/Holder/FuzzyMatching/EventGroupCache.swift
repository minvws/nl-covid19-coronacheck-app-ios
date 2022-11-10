/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Transport

protocol EventGroupCacheProtocol {
	
	func getEventResultWrapper(_ uniqueIdentifier: String) -> EventFlow.EventResultWrapper?
	
	func getEUCreditialAttributes(_ uniqueIdentifier: String) -> EuCredentialAttributes?
}

class EventGroupCache: EventGroupCacheProtocol {
	
	// MARK: - Cache
	
	internal var wrapperCache = SyncCache<String, EventFlow.EventResultWrapper>()
	internal var euCredentialAttributesCache = SyncCache<String, EuCredentialAttributes>()
	
	func getEventResultWrapper(_ uniqueIdentifier: String) -> EventFlow.EventResultWrapper? {
		
		if let wrapper = wrapperCache[uniqueIdentifier] {
			return wrapper
		}
		
		let eventGroups = Current.walletManager.listEventGroups()
		if let eventGroup = eventGroups.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
			
			guard let jsonData = eventGroup.jsonData else {
				return nil
			}
			
			if let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
			   let decodedPayloadData = Data(base64Encoded: object.payload),
			   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData) {
				
				wrapperCache[uniqueIdentifier] = wrapper
				return wrapper
			}
		}
		return nil
	}
	
	func getEUCreditialAttributes(_ uniqueIdentifier: String) -> EuCredentialAttributes? {
		
		if let attributes = euCredentialAttributesCache[uniqueIdentifier] {
			return attributes
		}
		
		let eventGroups = Current.walletManager.listEventGroups()
		if let eventGroup = eventGroups.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
			
			guard let jsonData = eventGroup.jsonData else {
				return nil
			}
			
			if let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData),
			   let credentialData = object.credential.data(using: .utf8),
			   let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData) {
				euCredentialAttributesCache[uniqueIdentifier] = euCredentialAttributes
				return euCredentialAttributes
			}
		}
		return nil
	}
}

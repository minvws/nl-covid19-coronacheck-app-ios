/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct RemoteEvent {
	
	let wrapper: EventFlow.EventResultWrapper
	let signedResponse: SignedResponse? // (optional, a scanned DCC does not have a signature)
}

extension RemoteEvent {
	
	func getEventsAsJSON() -> Data? {
		
		if let signedResponse,
		   let jsonData = try? JSONEncoder().encode(signedResponse) {
			return jsonData
		}
		if let dccEvent = wrapper.events?.first?.dccEvent,
		   let jsonData = try? JSONEncoder().encode(dccEvent) {
			return jsonData
		}
		return nil
	}
	
	var uniqueIdentifier: String {
		return (wrapper.events ?? []).compactMap { $0.unique }.joined(separator: "-")
	}
}

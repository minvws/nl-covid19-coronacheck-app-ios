/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol CouplingManaging {

	init(cryptoManager: CryptoManaging, networkManager: NetworkManaging )

	///  Convert a dcc to an event wrapper
	/// - Parameters:
	///   - dcc: The string representation of a digital covid certificate
	///   - couplingCode: the coupling code for the dcc
	/// - Returns: the event wrapper
	func convert(_ dcc: String, couplingCode: String) -> EventFlow.EventResultWrapper?

	/// Check the dcc and the coupling code
	/// - Parameters:
	///   - dcc: the scanned dcc
	///   - couplingCode: the coupling code
	///   - completion: completion handler
	func checkCouplingStatus(
		dcc: String,
		couplingCode: String,
		onCompletion: @escaping (Result<DccCoupling.CouplingResponse, ServerError>) -> Void)
}

class CouplingManager: CouplingManaging, Logging {

	let cryptoManager: CryptoManaging
	let networkManager: NetworkManaging

	required init(cryptoManager: CryptoManaging, networkManager: NetworkManaging) {

		self.cryptoManager = cryptoManager
		self.networkManager = networkManager
	}

	///  Convert a dcc to an event wrapper
	/// - Parameters:
	///   - dcc: The string representation of a digital covid certificate
	///   - couplingCode: the coupling code for the dcc
	/// - Returns: the event wrapper
	func convert(_ dcc: String, couplingCode: String) -> EventFlow.EventResultWrapper? {

		let dccEvent = EventFlow.DccEvent(credential: dcc, couplingCode: couplingCode)
		if let credentialData = dccEvent.credential.data(using: .utf8),
		   let euCredentialAttributes = cryptoManager.readEuCredentials(credentialData) {
			
			let wrapper =
				EventFlow.EventResultWrapper(
					providerIdentifier: EventFlow.paperproofIdentier,
					protocolVersion: "3.0",
					identity: euCredentialAttributes.identity,
					status: .complete,
					result: nil,
					events: [
						EventFlow.Event(
							type: "paperFlow",
							unique: dcc,
							isSpecimen: false,
							vaccination: nil,
							negativeTest: nil,
							positiveTest: nil,
							recovery: nil,
							dccEvent: dccEvent
						)
					]
				)
			return wrapper
		}
		return nil
	}

	/// Check the dcc and the coupling code
	/// - Parameters:
	///   - dcc: the scanned dcc
	///   - couplingCode: the coupling code
	///   - onCompletion: completion handler
	func checkCouplingStatus(
		dcc: String,
		couplingCode: String,
		onCompletion: @escaping (Result<DccCoupling.CouplingResponse, ServerError>) -> Void) {

		let dictionary: [String: AnyObject] = [
			"credential": dcc as AnyObject,
			"couplingCode": couplingCode as AnyObject
		]

		networkManager.checkCouplingStatus(dictionary: dictionary, completion: onCompletion)
	}
}

extension CouplingManager {

	static let vaccinationDCC = "HC1:NCFD20390T9WTWGVLK-49NJ3B0J$OCC*AX*4FBBGA2*70J+9FN0WMC..DWY01CC/J7D97TK0F90$PC5$CUZC$$5Y$5JPCT3E5JDLA73467463W5/A6..DX%DZJC6/D7WEM-D.H8B%E5$CLPCG/D+JDCY8 R7E1AL1BUIAI3DUOCT3EMPCG/DUOC+0AKECTHG4KCD3DX47B46IL6646H*6Z/E5JD%96IA74R6646307Q$D.UDRYA 96NF6L/5SW6Y57B$D% D3IA4W5646946846.96XJC$+D3KC.SCXJCCWENF6OF63W5+/6946WJCT3EJ+9%JC+QENQ4ZED+EDKWE3EFX3ET34X C:VDG7D82BUVDGECDZCCECRTCUOA04E4WEOPCN8FHZA1+92ZAQB9746VG7TS9 B9QY9JG6FG6R0A.G8*+A+NATB8MY8.Q6DK427BXB4S1G$MJ WML$8HVAW-3$32$$6WFJLV2K67.1KO9G3AOJ2PCQ8Q*H+KO6W7GV1DRJG4UI537%HZ7E.82R28KTP.DW.Z01-IV50U50RCWSW3L4"
}

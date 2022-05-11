/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol CouplingManaging {

	///  Convert a dcc to an event wrapper
	/// - Parameters:
	///   - dcc: The string representation of a digital covid certificate
	///   - couplingCode: the coupling code for the dcc
	/// - Returns: the event wrapper
	func convert(_ dcc: String, couplingCode: String?) -> EventFlow.EventResultWrapper?

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
	func convert(_ dcc: String, couplingCode: String?) -> EventFlow.EventResultWrapper? {

		let dccEvent = EventFlow.DccEvent(credential: dcc, couplingCode: couplingCode)
		if let credentialData = dccEvent.credential.data(using: .utf8),
		   let euCredentialAttributes = cryptoManager.readEuCredentials(credentialData) {
			
			let wrapper =
				EventFlow.EventResultWrapper(
					providerIdentifier: EventFlow.paperproofIdentier,
					protocolVersion: "3.0",
					identity: euCredentialAttributes.identity,
					status: .complete,
					events: [
						EventFlow.Event(
							type: "paperFlow",
							unique: dcc,
							isSpecimen: false,
							vaccination: nil,
							negativeTest: nil,
							positiveTest: nil,
							recovery: nil,
							dccEvent: dccEvent,
							vaccinationAssessment: nil
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

	static let vaccinationDCC = "HC1:NCFC20490T9WTWGVLKS79 1VYLTXZM8AVX*4FBBU42*70J+9DN03E54F3/Y1LOCY50.FK8ZKO/EZKEZ967L6C56GVC*JC1A6C%63W5Y96746TPCBEC7ZKW.CC9DCECS34$ CXKEW.CAWEV+A3+9K09GY8 JC2/DSN83LEQEDMPCG/DY-CB1A5IAVY87:EDOL9WEQDD+Q6TW6FA7C466KCN9E%961A6DL6FA7D46.JCP9EJY8L/5M/5546.96VF6.JCBECB1A-:8$966469L6OF6VX6FVCPD0KQEPD0LVC6JD846Y96*963W5.A6UPCBJCOT9+EDL8FHZ95/D QEALEN44:+C%69AECAWE:34: CJ.CZKE9440/D+34S9E5LEWJC0FD3%4AIA%G7ZM81G72A6J+9SG77N91R6E+9LCBMIBQCAYM8UIB51A9Y9AF6WA6I4817S6ZKH/C3*F*$GR4N2+5F8FM B$W6KU91A9WTO8S1QK87DBBMHDKFT*UMNCI3V$LS.QFWMF18W6TH5$9W+4QZLU71.5DB73000FGWU/0CRF"
}

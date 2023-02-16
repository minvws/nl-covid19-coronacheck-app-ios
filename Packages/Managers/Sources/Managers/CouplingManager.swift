/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared
import Models

public protocol CouplingManaging {

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

public class CouplingManager: CouplingManaging {

	public let cryptoManager: CryptoManaging
	public let networkManager: NetworkManaging

	public required init(cryptoManager: CryptoManaging, networkManager: NetworkManaging) {

		self.cryptoManager = cryptoManager
		self.networkManager = networkManager
	}

	///  Convert a dcc to an event wrapper
	/// - Parameters:
	///   - dcc: The string representation of a digital covid certificate
	///   - couplingCode: the coupling code for the dcc
	/// - Returns: the event wrapper
	public func convert(_ dcc: String, couplingCode: String?) -> EventFlow.EventResultWrapper? {

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
	public func checkCouplingStatus(
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
	
	public static let vaccinationDCC = "HC1:NCFC20490T9WTWGVLKS79 1VYLTXZM8AVX*4FBBU42*70J+9DN03E54F3/Y1LOCY50.FK8ZKO/EZKEZ967L6C56GVC*JC1A6C%63W5Y96746TPCBEC7ZKW.CC9DCECS34$ CXKEW.CAWEV+A3+9K09GY8 JC2/DSN83LEQEDMPCG/DY-CB1A5IAVY87:EDOL9WEQDD+Q6TW6FA7C466KCN9E%961A6DL6FA7D46.JCP9EJY8L/5M/5546.96VF6.JCBECB1A-:8$966469L6OF6VX6FVCPD0KQEPD0LVC6JD846Y96*963W5.A6UPCBJCOT9+EDL8FHZ95/D QEALEN44:+C%69AECAWE:34: CJ.CZKE9440/D+34S9E5LEWJC0FD3%4AIA%G7ZM81G72A6J+9SG77N91R6E+9LCBMIBQCAYM8UIB51A9Y9AF6WA6I4817S6ZKH/C3*F*$GR4N2+5F8FM B$W6KU91A9WTO8S1QK87DBBMHDKFT*UMNCI3V$LS.QFWMF18W6TH5$9W+4QZLU71.5DB73000FGWU/0CRF"
	public static let vaccinationCouplingCode = "ZKGBKH"
	
	public static let expiredDCC = "HC1:NCF720990T9WTWGVLK-49NJ3B0J$OCC*AX*4FBBAL1*70J+9FN0FMCJBAWY0TBCKX3D97TK0F90$PC5$CUZC$$5Y$5JPCT3E5JDLA73467463W5/A6..DX%DZJC3/D0I834EA4FXKEW.C9WEDH8E1AL1BUIAI3DUOCT3EMPCG/DUOC+0AKECTHG4KCD3DX47B46IL6646H*6Z/E5JD%96IA74R6646307Q$D.UDRYA 96NF6L/5SW6Y57B$D% D3IA4W5646946846.96XJC$+D3KC.SCXJCCWENF6OF63W5+/6-96WJCT3EJ+9%JC+QENQ4ZED+EDKWE3EFX3ET34X C:VDG7D82BUVDGECDZCCECRTCUOA04E4WEOPCN8FHZA1+92ZAQB9746VG7TS9$S85OALTA:HALB9+*8J:6G09XTAZR6.Q6%K427BBV6-MRUDKRHA*WQRV50P9Y7L69E/2AS/I3GF0 RM97DC3:QSS79J-9$*SA:ED37RJAFYQLM0Y8O$EF$E2E*HDHDIA5XIORJEV50U50-CWJ0TQ4"
	public static let expiredCouplingCode = "4R4NZP"
	
	public static let boosterDCC = "HC1:NCF820890T9WTWGVLK:492RDK$7JHEH:KX*4FBB-Q1*70J+9DN03E55F3TH3AG7Y50.FK8ZKO/EZKEZ967L6C56GVC*JC1A6C%63W5Y96746TPCBEC7ZKW.C%DDDZC.H8B%E5$CLPCG/D%DD*X8AH8MZAGY8 JC:.D.H8WJCI3D5WEAH8SH87:EDOL9WEQDD+Q6TW6FA7C466KCN9E%961A6DL6FA7D46.JCP9EJY8L/5M/5546.96VF6.JCBECB1A-:8$966469L6OF6VX6FVCBJ0KQEBJ0LVC6JD846KF6F463W5.A6UPCBJCOT9+EDL8FHZ95/D QEALEN44:+C%69AECAWE:34: CJ.CZKE9440/D+34S9E5LEWJC0FD3%4AIA%G7ZM81G72A6J+9 G7RR6SY9%IB8N9.HA-A81T9YIB%S89Y9AF64M6V58TMLO7N09KW47NKH*J6FVC%ELZYLPFK$WT2357TR.VUAHE1.EKY1V1MMME+.ENCM-6IO+PK:KJLG43PE-1S%SE2QY:HYUNGTO000FGWU1LCPF"
	public static let boosterCouplingCode = "RPQRFB"
	
	public static let foreignDCC = "HC1:NCFF20190T9WTWGVLK-49NJ3B0J$OCC*AX*4FBBXL2*70HS8FN0BKCYBCWY0BKCYGBD97TK0F90$PC5$CUZC$$5Y$5JPCT3E5JDLA73467463W5/A6..DX%DZJC4/DK/EM-D7195$CLPCG/DP8DNB8-R73Y8UIAI3DY-C04E*KEZ CI3D8WE-M8EIA$B9KECTHG4KCD3DX47B46IL6646H*6Z/E5JD%96IA74R6646307Q$D.UDRYA 96NF6L/5SW6Y57B$D% D3IA4W5646946846.96XJC$+D3KC.SCXJCCWENF6PF63W5KF6F46WJCT3EHS8%JC+QENQ4ZED+EDKWE3EFX3ET34X C:VDG7D82BUVDGECDZCCECRTCUOA04E4WEOPCN8FHZA1+92ZAQB9746VG7TS9W595X6*Y9IIAEL6NY8H69Y6A3ZAR0A.Q6SK427B:/IBKCZGAW*5H2FE/7ZAOE8JO2DP:DHG1.MQCI1:.C.WIOBR9W93*R38UFMRQVNLX6856PMCH+49XC3IRK4F339M14R5NTJAV50U50BDWQGR$4"
}

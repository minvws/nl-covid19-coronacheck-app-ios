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
		onCompletion: @escaping (Result<DccCoupling.CouplingResponse, NetworkError>) -> Void)
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
		if let identity = dccEvent.identity(cryptoManager: cryptoManager) {

			let wrapper =
				EventFlow.EventResultWrapper(
					providerIdentifier: "DCC",
					protocolVersion: "3.0",
					identity: identity,
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
		onCompletion: @escaping (Result<DccCoupling.CouplingResponse, NetworkError>) -> Void) {

		let dictionary: [String: AnyObject] = [
			"credential": dcc as AnyObject,
			"couplingCode": couplingCode as AnyObject
		]

		networkManager.checkCouplingStatus(dictionary: dictionary, completion: onCompletion)
	}
}

extension CouplingManager {

	static let testDCC = "HC1:NCF%RN%TS3DH0RGPJB/IB-OM7533SR7694RI3XH8/FWP5IJBVGAMAU5PNPF6R:5SVBWVBDKBYLDZ4D74DWZJ$7K+ CREDRCK*9C%PD8DJI7JSTNB95326HW4*IOQAOGU7$35+Y5MT4K0P*5PP:7X$RL353X7IKRE:7SA7G6M/NRO9SQKMHEE5IAXMFU*GSHGRKMXGG6DB-B93:GQBGZHHBIH5C9HFEC+GYHILIIX2MELNJIKCCHWIJNKMQ-ILKLXGGN+IRB84C9Q2LCIJ/HHKGL/BHOUB7IT8DJUIJ6DBSJLI7BI8AZ3CVOJ3BI9IL NILMLSVB*8BEPLA8KC42UIIUHSBKB+GIAZI3DJ/JAJZIR9KICT.XI/VB6TSYIJGDBGIA181:0TLOJJPACGKC2KRTI-8BEPL3DJ/LKQVBE2C*NIKYJIGK:H3J1DKVTQEDK8C+2TDSCNTCNJS6F3W.C$USE$2:*TIT3C7D8MS7LCTO3MMSSHT0$U58PLY3 ZRA5PUF7MDN QKI7B$WKL 6Q:S14GW4Q:LRERC6FPK1J*IUIH7S3J UQ2VQQ3ONV2CVR/TFFSQJ8KP.BENIQETGK6112U50-BW/IVK5"

	static let recoveryDCC = "HC1:NCF%RN%TS3DH0RGPJB/IB-OM7533SR*BH9M9*VIHWF S4KHRFH2SZ9OUM:UC*GP-S4FT5D75W9AAABE34+V4YC5/HQ/ PHCR+9AFDOEA7IB65C94JB11L0PL:OA1FD$JDOKEH-BK2L.UL4TIXADMPD9JAW/B:OA1JA6LFBE9NUIGOA%FAGUU0QIRR97I2HOAXL92L0: KQMK8J4RK46YB9M65QC2%KI*V.18N$K-PSJY2W*PP+P8OI.I9Y*VSV0I+QWZJAQ12KUL JS%O$UA9*OXQ29HS9.VAOI5XIKXC-B5P54NB27FCYE9*FJRLDQC8$.AJ5QH*AA:G8/FV+AM8WJ1E8CA0D89.B40LL5OS$4AGCZ3SW.89/H%Y1W1W*$UAY5LYQ735$CF$YR7YMACPX$3F:O0MBE4LSB2+E7XVJ-OKYO3T6IA6E/TN:T2JL3N0JK1KEL4COE8DQ%5KK1LS.RR3SRB3*50000FGW DP+ME"

	static let recoveryDCC2 = "HC1:NCF%RN%TS3DHHYOUUHO.KY669APCIDGI47X5XW9PYUOGI0-VD*OM*4 9EPGDCV4*XUA2PWKP/HLIJLKNF8JFHJP7NVDEBR0JC%05$0CNNZ1HIGF5JNBPIHVU%$J8Q9CPACPIGSU6SQ4+VIVOMSG3UQ3OI:TUCPI2YU3OI4.VMF2CG3805CZKHKB-43.E3KD3OAJ6*K6ZCY73JC3DG34LTIJ3SZ4I25FMV3ZCU3B5IVV5TN%2UP20J5/5LEBFD-48YIM557AL XK$%2XE557TT25-037:2LS4JYK/Y6LWTXD3/-KAMG.%8J.45CBZW4:.AY GNNV-$GXQFY73OMBMNV5X8AWN7YVZ GMDF1INV5HWT0$OFOSVSLJI85709U$OPXV.S7FJMM2RMALR17$GH%YC3IJYZB46LY$FUOLBDGODE87TP%2ALP5ZUE.V0XIEY2GPLLJRKN5 .UZ.H/9LF.9GVI-JA-2WDQIV50U50JDW3*RU5"

	static let vaccinationDCC = "HC1:NCFO20$80T9WTWGVLK-49NJ3B0J$OCC*AX*4FBB.R3*70J+9DN03E52F3%0US.3Y50.FK8ZKO/EZKEZ967L6C56GVC*JC1A6QW63W5KF6746TPCBEC7ZKW.CSEE*KEQPC.OEFOAF$DN34VKE0/DLPCG/DSEE5IA$M8NNASNAQY9 R7.HAB+9 JC:.DNUAU3EI3D5WE TAQ1A7:EDOL9WEQDD+Q6TW6FA7C466KCN9E%961A6DL6FA7D46.JCP9EJY8L/5M/5546.96VF6.JCBECB1A-:8$966469L6OF6VX6FVCPD0KQEPD0LVC6JD846Y96D463W5307UPCBJCOT9+EDL8FHZ95/D QEALEN44:+C%69AECAWE:34: CJ.CZKE9440/D+34S9E5LEWJC0FD3%4AIA%G7ZM81G72A6J+9QG7OIBENA.S90IAY+A17A+B9:CB*6AVX8AF6F:5678M2927SM6NAN24WKP0VTMO8.CMJF1CF-*7%XN3R0C0E45L0EKUGEA-SL0HYN71PBTWHCITDHPIHG/A7%8U9PEBHEPD9DD4$O4000FGW5HIWGG"
}

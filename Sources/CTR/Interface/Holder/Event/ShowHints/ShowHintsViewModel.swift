/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Transport
import Shared
import ReusableViews
import Persistence
import Resources

final class ShowHintsViewModel {
	
	weak var coordinator: (OpenUrlProtocol & EventCoordinatorDelegate)?
	
	private enum Hint: String, CaseIterable, Equatable {
		case domesticVaccinationCreated = "domestic_vaccination_created"
		case domesticVaccinationRejected = "domestic_vaccination_rejected"
		
		case vaccinationDoseCorrectionApplied = "vaccination_dose_correction_applied"
		case vaccinationDoseCorrectionNotApplied = "vaccination_dose_correction_not_applied"
		
		case internationalVaccinationCreated = "international_vaccination_created"
		case internationalVaccinationRejected = "international_vaccination_rejected"
		
		case domesticRecoveryCreated = "domestic_recovery_created"
		case domesticRecoveryRejected = "domestic_recovery_rejected"
		
		case internationalRecoveryCreated = "international_recovery_created"
		case internationalRecoveryRejected = "international_recovery_rejected"
		case internationalRecoveryTooOld = "international_recovery_too_old"
		
		case domesticNegativeTestCreated = "domestic_negativetest_created"
		case domesticNegativeTestRejected = "domestic_negativetest_rejected"
		
		case internationalNegativeTestCreated = "international_negativetest_created"
		case internationalNegativeTestRejected = "international_negativetest_rejected"
		
		case negativeTestWithoutVaccineAssessment = "negativetest_without_vaccinationassessment"
		case vaccinationAssessmentMissingSupportingNegativeTest = "vaccinationassessment_missing_supporting_negativetest"
		
		case domesticVaccinationAssessmentCreated = "domestic_vaccinationassessment_created"
		case domesticVaccinationAssessmentRejected = "domestic_vaccinationassessment_rejected"
	}
	
	private enum EndState: Equatable {
		case internationalQROnly
		case vaccinationsAndRecovery
		case internationalVaccinationAndRecovery
		case recoveryOnly
		case recoveryAndDosisCorrection
		case noRecoveryButDosisCorrection
		case recoveryTooOld
		case addVaccinationAssessment
		case cantCreateCertificate(errorCode: ErrorCode.ClientCode)
		
		var title: String {
			switch self {
				case .internationalQROnly:
					return L.holder_listRemoteEvents_endStateInternationalQROnly_title()
				case .vaccinationsAndRecovery:
					return L.holder_listRemoteEvents_endStateVaccinationsAndRecovery_title()
				case .internationalVaccinationAndRecovery:
					return L.holder_listRemoteEvents_endStateInternationalVaccinationAndRecovery_title()
				case .recoveryOnly:
					return L.holder_listRemoteEvents_endStateRecoveryOnly_title()
				case .recoveryAndDosisCorrection:
					return L.holder_listRemoteEvents_endStateRecoveryAndDosisCorrection_title()
				case .noRecoveryButDosisCorrection:
					return L.holder_listRemoteEvents_endStateNoRecoveryButDosisCorrection_title()
				case .recoveryTooOld:
					return L.holder_listRemoteEvents_endStateRecoveryTooOld_title()
				case .addVaccinationAssessment:
					return L.holder_event_negativeTestEndstate_addVaccinationAssessment_title()
				case .cantCreateCertificate:
					return L.holder_listRemoteEvents_endStateCantCreateCertificate_title()
			}
		}
		
		func message(eventMode: EventMode) -> String {
			
			switch self {
				case .internationalQROnly:
					return L.holder_listRemoteEvents_endStateInternationalQROnly_message()
				case .vaccinationsAndRecovery:
					return L.holder_listRemoteEvents_endStateVaccinationsAndRecovery_message()
				case .internationalVaccinationAndRecovery:
					return L.holder_listRemoteEvents_endStateInternationalVaccinationAndRecovery_message()
				case .recoveryOnly:
					return L.holder_listRemoteEvents_endStateRecoveryOnly_message()
				case .recoveryAndDosisCorrection:
					return L.holder_listRemoteEvents_endStateRecoveryAndDosisCorrection_message()
				case .noRecoveryButDosisCorrection:
					return L.holder_listRemoteEvents_endStateNoRecoveryButDosisCorrection_message()
				case .recoveryTooOld:
					return L.holder_listRemoteEvents_endStateRecoveryTooOld_message()
				case .addVaccinationAssessment:
					return L.holder_event_negativeTestEndstate_addVaccinationAssessment_body()
				case .cantCreateCertificate(let errorCode):
					return L.holder_listRemoteEvents_endStateCantCreateCertificate_message(
						eventMode.errorStateLocalization.lowercased(),
						ErrorCode(flow: eventMode.flow, step: .signer, clientCode: errorCode).description
					)
				}
		}
		
		var buttonTitle: String {
			if case .addVaccinationAssessment = self {
				return L.holder_event_negativeTestEndstate_addVaccinationAssessment_button_complete()
			} else {
				return L.general_toMyOverview()
			}
		}
	}
	
	private enum Error: Swift.Error {
		case unknownHintCombination
	}
	
	private let endState: EndState
	
	// MARK: - Bindable
	
	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String
	
	// MARK: - Initializer
	
	init?(hints rawHints: NonemptyArray<String>, eventMode: EventMode, coordinator: OpenUrlProtocol & EventCoordinatorDelegate) {
		
		let hints = rawHints.contents.compactMap { Hint(rawValue: $0.lowercased()) }
		
		guard let endState = try? Self.convert(hints: hints) else { return nil }

		self.endState = endState
		self.coordinator = coordinator
		self.title = endState.title
		self.message = endState.message(eventMode: eventMode)
		self.buttonTitle = endState.buttonTitle
	}
	
	// MARK: - Methods
	
	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url, inApp: true)
	}
	
	func userTappedCallToActionButton() {
		
		switch endState {
			case .addVaccinationAssessment:
				coordinator?.showHintsScreenDidFinish(.shouldCompleteVaccinationAssessment)
			default:
				coordinator?.showHintsScreenDidFinish(.stop)
		}
	}
	
	// `throws` if it's an unknown hint combination
	// return nil if it's a valid "no end-state" hint combination
	private static func convert(hints: [Hint]) throws -> EndState? {
		guard hints.isNotEmpty else { return nil }
		
		let anyRecoveryCreated = hints.contains(.domesticRecoveryCreated) || hints.contains(.internationalRecoveryCreated)
		let bothRecoveriesCreated = hints.contains(.domesticRecoveryCreated) && hints.contains(.internationalRecoveryCreated)
		let anyRecoveryRejected = hints.contains(.domesticRecoveryRejected) || hints.contains(.internationalRecoveryRejected)
		let anyVaccinationCreated = hints.contains(.domesticVaccinationCreated) || hints.contains(.internationalVaccinationCreated)
		let anyVaccinationRejected = hints.contains(.domesticVaccinationRejected) || hints.contains(.internationalVaccinationRejected)
		let anyNegativeTestCreated = hints.contains(.domesticNegativeTestCreated) || hints.contains(.internationalNegativeTestCreated)
		let anyNegativeTestRejected = hints.contains(.domesticNegativeTestRejected) || hints.contains(.internationalNegativeTestRejected)
		
		let mentionsVaccinations = anyVaccinationCreated || anyVaccinationRejected
		
		if mentionsVaccinations {
			guard anyVaccinationRejected || anyRecoveryCreated else { return nil }
			
			if anyRecoveryCreated {
				guard anyVaccinationCreated else { return .recoveryOnly }
				if hints.contains(.internationalVaccinationCreated) {
					if hints.contains(.domesticVaccinationRejected)
						&& hints.contains(.vaccinationDoseCorrectionNotApplied) {
						return .internationalVaccinationAndRecovery
					} else if hints.contains(.vaccinationDoseCorrectionApplied)
								|| hints.contains(.vaccinationDoseCorrectionNotApplied) {
						return .vaccinationsAndRecovery
					} else {
						throw Error.unknownHintCombination
					}
				} else {
					throw Error.unknownHintCombination
				}
			} else if hints.contains(.domesticVaccinationRejected) {
				guard hints.contains(.internationalVaccinationRejected) else { return .internationalQROnly }
				
				if hints.contains(.vaccinationDoseCorrectionNotApplied)
					&& hints.contains(.domesticRecoveryRejected)
					&& hints.contains(.internationalRecoveryRejected) {
					return .cantCreateCertificate(errorCode: .hintsError0510)
				} else {
					return .cantCreateCertificate(errorCode: .hintsError059)
				}
			} else {
				throw Error.unknownHintCombination
			}
		} else { // No vaccinations mentioned
			
			guard !hints.contains(.negativeTestWithoutVaccineAssessment) else { return .addVaccinationAssessment }
			
			if bothRecoveriesCreated && hints.contains(.vaccinationDoseCorrectionApplied) {
				return .recoveryAndDosisCorrection
			}
			
			guard !hints.contains(.vaccinationAssessmentMissingSupportingNegativeTest)
					&& !hints.contains(.domesticVaccinationAssessmentCreated)
					&& !anyNegativeTestCreated
					&& !anyRecoveryCreated
			else {
				return nil
			}
			
			guard !anyNegativeTestRejected else {
				return .cantCreateCertificate(errorCode: .hintsError0512)
			}
			guard !hints.contains(.domesticVaccinationAssessmentRejected) else {
				return .cantCreateCertificate(errorCode: .hintsError0513)
			}
			guard anyRecoveryRejected else { throw Error.unknownHintCombination }
			
			if hints.contains(.vaccinationDoseCorrectionApplied) {
				return .noRecoveryButDosisCorrection
			} else if hints.contains(.internationalRecoveryTooOld) {
				return .recoveryTooOld
			} else {
				return .cantCreateCertificate(errorCode: .hintsError0511)
			}
		}
	}
}

private extension EventMode {
 
	/// Op dit moment kunnen we geen bewijs maken van je _____.
	var errorStateLocalization: String {
		switch self {
			case .paperflow: return L.general_scannedQRCode() // gescande QR-code
			case .vaccinationAndPositiveTest: return L.general_retrievedDetails() // opgehaalde gegevens
			case .recovery: return L.general_positiveTest() // positive testuitslag
			case .test: return L.general_negativeTest() // negative testuitslag
			case .vaccination: return L.general_vaccination() // vaccinatie
			case .vaccinationassessment: return L.general_vaccinationAssessment() // vaccinatiebeoordeling
		}
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {
	
	// 059: couldn't create certificate because of Domestic_vaccination_rejected, International_vaccination_rejected hints
	static let hintsError059 = ErrorCode.ClientCode(value: "059")
	
	// 0510 (060): couldn't create certificate because of Domestic_Vaccination_rejected, International_vaccination_rejected, Vaccination_dose_correction_not_applied, Domestic_recovery_rejected, International_recovery_rejected hints
	static let hintsError0510 = ErrorCode.ClientCode(value: "0510")
	
	// 0511 (061): couldn't create certificate because of Domestic_recovery_rejected, International_recovery_rejected hints
	static let hintsError0511 = ErrorCode.ClientCode(value: "0511")
	
	// 0512 (062): couldn't create certificate because of Domestic_negativetest_rejected, International_negativetest_rejected hints
	static let hintsError0512 = ErrorCode.ClientCode(value: "0512")
	
	// 0513: couldn't create certificate because of Domestic_vaccinationassessment_rejected hint
	static let hintsError0513 = ErrorCode.ClientCode(value: "0513")
}

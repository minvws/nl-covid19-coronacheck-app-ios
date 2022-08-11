/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

final class ShowHintsViewModel {
	
	weak var coordinator: (OpenUrlProtocol & EventCoordinatorDelegate)?
	
	enum Mode {
		case standard
		case shouldCompleteVaccinationAssessment
	}
	
	private let mode: Mode
	
	// MARK: - Bindable
	
	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String = L.general_toMyOverview()
	
	// MARK: - Initializer
	
	init?(hints: NonemptyArray<String>, coordinator: OpenUrlProtocol & EventCoordinatorDelegate) {
		
		let hintsMappedToMessages = hints.contents
			.compactMap(Self.sanitizeHintKey)
			.compactMap { safeHintKey -> String? in
				let localized = NSLocalizedString(safeHintKey, comment: "")
				guard localized != safeHintKey else { return nil } // we don't want to show the key if there's no translation
				return localized
			}
		
		guard hintsMappedToMessages.isNotEmpty else { return nil }
		
		self.coordinator = coordinator
		self.message = hintsMappedToMessages
			.map { "<p>\($0)</p>" }
			.joined(separator: "\n")
		
		// Special case..
		if hints.contents.contains(where: { $0 == "negativetest_without_vaccinationassessment" }) {
			self.mode = .shouldCompleteVaccinationAssessment
		} else {
			self.mode = .standard
		}
		
		switch mode {
			case .standard:
				self.title = L.holder_eventHints_title()
				self.buttonTitle = L.general_toMyOverview()
			case .shouldCompleteVaccinationAssessment:
				self.title = L.holder_event_negativeTestEndstate_addVaccinationAssessment_title()
				self.buttonTitle = L.holder_event_negativeTestEndstate_addVaccinationAssessment_button_complete()
		}
	}
	
	// MARK: - Methods
	
	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url, inApp: true)
	}
	
	func userTappedCallToActionButton() {
		switch mode {
			case .standard:
				coordinator?.showHintsScreenDidFinish(.stop)
			case .shouldCompleteVaccinationAssessment:
				coordinator?.showHintsScreenDidFinish(.shouldCompleteVaccinationAssessment)
		}
	}
	
	/// Performs a basic sanity/safety check that the key consists of only alphanumeric and "_":
	private static func sanitizeHintKey(_ rawHintKey: String) -> String? {
		var allowedCharacters = CharacterSet.alphanumerics
		allowedCharacters.insert(charactersIn: "_")

		let hintKeyCharacters = CharacterSet(charactersIn: rawHintKey)
		
		guard hintKeyCharacters.isSubset(of: allowedCharacters) else { return nil }
		return rawHintKey
	}
}

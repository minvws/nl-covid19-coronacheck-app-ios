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
	
	@Bindable private(set) var title: String = L.holder_eventHints_title()
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String = L.general_toMyOverview()
	
	// MARK: - Initializer
	
	init(hints: [String], coordinator: OpenUrlProtocol & EventCoordinatorDelegate) {
		
		let hints = ["negativetest_without_vaccinationasssesment"]
		self.coordinator = coordinator
		self.message = hints
			.map { "<p>\($0)</p>" }
			.joined(separator: "\n")
		
		// Special case..
		if hints.contains(where: { $0 == "negativetest_without_vaccinationasssesment" }) {
			mode = .shouldCompleteVaccinationAssessment
		} else {
			mode = .standard
		}
		
		switch mode {
		case .standard:
			buttonTitle = L.general_toMyOverview()
		case .shouldCompleteVaccinationAssessment:
			buttonTitle = L.holder_event_negativeTestEndstate_addVaccinationAssessment_button_complete()
		}
	}
	
	// MARK: - Methods
	
	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url, inApp: true)
	}
	
	func navigateToDashboard() {
		switch mode {
		case .standard:
			coordinator?.showHintsScreenDidFinish(.stop)
		case .shouldCompleteVaccinationAssessment:
			coordinator?.showHintsScreenDidFinish(.shouldCompleteVaccinationAssessment)
		}
	}
}

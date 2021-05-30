/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class VaccinationStartViewModel: Logging {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	init(coordinator: EventCoordinatorDelegate & OpenUrlProtocol) {

		self.coordinator = coordinator
	}

	func backButtonTapped() {
		
		coordinator?.vaccinationStartScreenDidFinish(.back)
	}

	func primaryButtonTapped() {

		coordinator?.vaccinationStartScreenDidFinish(.continue(value: nil))
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
}

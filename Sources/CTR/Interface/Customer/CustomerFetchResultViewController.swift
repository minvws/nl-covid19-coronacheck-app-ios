/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Sodium

class CustomerFetchResultViewController: BaseViewController {

	weak var coordinator: CustomerCoordinatorDelegate?

	/// The date formatter for the timestamps
	lazy var dateFormatter: DateFormatter = {

		let isoFormatter = DateFormatter()
		isoFormatter.dateFormat = "dd MMM YYYY - HH:mm"
		return isoFormatter
	}()

	var userIdentifier: String?

	let sceneView = MainView()

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		title = "Burger Fetch Result"

		sceneView.primaryTitle = "Login met Digid"
		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.fetchTestResults()
		}

		sceneView.secondaryButtonTappedCommand = { [weak self] in

			self?.coordinator?.navigateToCustomerQR()
		}
    }

	func fetchTestResults() {

		guard let identifier = userIdentifier else {
			return
		}

		APIClient().getTestResults(identifier: identifier) { [weak self] envelope in

			guard let strongSelf = self else {
				return
			}

			strongSelf.coordinator?.setTestResultEnvelope(envelope)
			strongSelf.sceneView.message = ""

			if let envelope = envelope {
				for result in envelope.testResults {

					let date = Date(timeIntervalSince1970: TimeInterval(result.dateTaken))
					strongSelf.sceneView.message += "Test op \(strongSelf.dateFormatter.string(from: date)): \(result.result)\n"
				}
			}
			// Show the button
			strongSelf.sceneView.secondaryTitle = "Genereer toegangsbewijs"
		}
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierStartViewController: BaseViewController {

	/// The date formatter for the timestamps
	lazy var dateFormatter: DateFormatter = {

		let isoFormatter = DateFormatter()
		isoFormatter.dateFormat = "dd MMM YYYY - HH:mm"
		return isoFormatter
	}()

	weak var coordinator: VerifierCoordinatorDelegate?

	var event: Event? {
		didSet {
			if let event = event {
				var tests = "Valid Tests:"
				for type in event.validTestsTypes {
					tests += " \(type.name),"
				}
				tests = String(tests.dropLast())
				let from = Date(timeIntervalSince1970: TimeInterval(event.validFrom!))
				let to = Date(timeIntervalSince1970: TimeInterval(event.validTo!))
				sceneView.message = "Event: \(event.title ?? "")\n\(tests)\nGeldig van \(dateFormatter.string(from: from))\n Geldig tot \(dateFormatter.string(from: to))"
 			}
		}
	}

	let sceneView = MainView()

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		title = "Verifier Start"

		sceneView.primaryTitle = "Start met scannen van bezoekers" // Login als Agent"
//		sceneView.secondaryTitle = "Scan Customer"

		sceneView.primaryButtonTappedCommand = { [weak self] in

//			self?.coordinator?.navigateToAgent()
			self?.coordinator?.navigateToCustomerScan()
		}

//		sceneView.secondaryButtonTappedCommand = { [weak self] in
//
//			self?.coordinator?.navigateToCustomerScan()
//		}

		sceneView.message = "Meer informatie over deze app."
    }
}

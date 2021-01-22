/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import AVFoundation
import UIKit

class CustomerScanViewController: ScanViewController {

	/// The date formatter for the timestamps
	lazy var dateFormatter: DateFormatter = {

		let isoFormatter = DateFormatter()
		isoFormatter.dateFormat = "dd MMM YYYY - HH:mm"
		return isoFormatter
	}()

	weak var coordinator: CustomerCoordinatorDelegate?

	var issuers: [Issuer] = []
	var testResults: TestResultEnvelope?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		title = "Burger Scan"
    }

	func displayEvent(_ envelope: EventEnvelope) {

		let validFrom = Date(timeIntervalSince1970: TimeInterval(envelope.event.validFrom ?? 0))
		let validTo = Date(timeIntervalSince1970: TimeInterval(envelope.event.validTo ?? 0))

		let ac = UIAlertController(
			title: "Event found",
			message: "Event: \(envelope.event.title ?? "")\nLocatie: \(envelope.event.location?.name ?? "")\nvan: \(dateFormatter.string(from: validFrom))\ntot: \(dateFormatter.string(from: validTo))",
			preferredStyle: .alert
		)
		ac.addAction(UIAlertAction(title: "Cancel", style: .default))

		ac.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in

			self?.coordinator?.setEvent(envelope)
			self?.coordinator?.navigateToCustomerQR()
		})
		present(ac, animated: true)
	}

	override func found(code: String) {
		super.found(code: code)

		do {
			if let data = code.data(using: .utf8) {
				let event = try JSONDecoder().decode(EventEnvelope.self, from: data)
				checkEvent(event)
			}
		} catch let error {
			print("CTR: error! \(error)")
		}
	}

	func checkEvent(_ envelope: EventEnvelope) {

		guard let testResultsEnvelope = testResults else {
			print("CTR: error checking, no test results")
			displayEvent(envelope)
			return
		}

		var foundValidTest: TestResult?

		for validTestType in envelope.event.validTestsTypes {
			for userTest in testResultsEnvelope.testResults {

				// Same Test Type (PCR etc)
				if userTest.testType == validTestType.identifier {

					// Still Valid
					if userTest.dateTaken + Int64(validTestType.maxValidity) >= Int64(Date().timeIntervalSince1970) {

						print("CTR: Found a test for this event: \(validTestType.name), result was \(userTest.result)\n")
						// Replace or store
						if let existing = foundValidTest {

							if userTest.dateTaken >= existing.dateTaken {
								foundValidTest = userTest
							}

						} else {
							foundValidTest = userTest
						}
					} else {
						print("CTR: Test expired for this event")
					}
				} else {
					print("CTR: Test not for this event")
				}
			}
		}
		displayEvent(envelope)
		print("CTR: Check Event result: \(String(describing: foundValidTest))")
//		coordinator?.setTestResult(foundValidTest)
	}
}

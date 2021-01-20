/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import AVFoundation
import UIKit

class CustomerScanViewController: ScanViewController {

	weak var coordinator: CustomerCoordinatorDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		title = "Burger Scan"
    }

	func displayEvent(_ event: Event) {

		let ac = UIAlertController(
			title: "Event found",
			message: "Event: \(event.title)\n Locatie: \(event.location)\n tijd: \(event.time)",
			preferredStyle: .alert
		)
		ac.addAction(UIAlertAction(title: "Cancel", style: .default))

		ac.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in

			self?.coordinator?.setEvent(event)
			self?.coordinator?.navigateToCustomerQR()
		})
		present(ac, animated: true)
	}

	override func found(code: String) {
		super.found(code: code)

		do {
			if let data = code.data(using: .utf8) {
				let event = try JSONDecoder().decode(Event.self, from: data)
				displayEvent(event)
			}
		} catch let error {
			print("error! \(error)")
		}

	}

}

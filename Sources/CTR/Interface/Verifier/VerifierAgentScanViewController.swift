/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierAgentScanViewController: ScanViewController {

	weak var coordinator: VerifierCoordinatorDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		title = "Verifier Agent Scan"
	}

	override func found(code: String) {

		super.found(code: code)

		do {
			if let data = code.data(using: .utf8) {
				let result = try JSONDecoder().decode(AgentEnvelope.self, from: data)
				print(result)
				coordinator?.setAgentEnvelope(result)
				coordinator?.dismiss()
                                                                                			}
		} catch let error {
			print("CTR: error! \(error)")
		}
	}
}

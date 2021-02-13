/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierScanViewModel: Logging {

	var loggingCategory: String = "VerifierScanViewModel"

	/// The crypto manager
	var cryptoManager: CryptoManaging = CryptoManager()

	/// Coordination Delegate
	weak var coordinator: VerifierCoordinatorDelegate?

	// MARK: - Bindable properties

	@Bindable private(set) var primaryButtonTitle: String

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - userIdentifier: the user identifier
	init(
		coordinator: VerifierCoordinatorDelegate) {

		self.coordinator = coordinator
		primaryButtonTitle = "scan opnieuw"
	}

	func parseQRMessage(_ message: String) {

		let result = cryptoManager.verifyQRMessage(message)
		coordinator?.setScanResult(result)
		coordinator?.navigateToScanResult()
	}
}

class VerifierScanViewController: ScanViewController {

	private let viewModel: VerifierScanViewModel

	init(viewModel: VerifierScanViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		// Do any additional setup after loading the view.
		title = "Verifier Scan"

		viewModel.$primaryButtonTitle.binding = {

			self.sceneView.primaryTitle = $0
		}
	}
	override func found(code: String) {

		viewModel.parseQRMessage(code)
	}
}

//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenScanViewModel: Logging {

	var loggingCategory: String = "TokenScanViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// Start scanning
	@Bindable private(set) var startScanning: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator
		self.title = .holderTokenScanTitle
		self.message = .holderTokenScanMessage
	}

	func parseCode(_ code: String) {

		do {
			let object = try JSONDecoder().decode(RequestToken.self, from: Data(code.utf8))
			self.logDebug("Response Object: \(object)")
			coordinator?.navigateToTokenEntry(object)
		} catch {

			self.logError("error: \(error)")
			self.startScanning = true
			
		}
	}
}


class TokenScanViewController: ScanViewController {

	private let viewModel: TokenScanViewModel

	init(viewModel: TokenScanViewModel) {

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

		viewModel.$title.binding = { self.title = $0 }

		viewModel.$message.binding = { self.sceneView.message = $0 }

		viewModel.$startScanning.binding = {
			if $0, self.captureSession?.isRunning == false {
				self.captureSession.startRunning()
			}
		}

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		// Force navigation title color to white
		let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.tintColor = .white
	}

	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		// Reset navigation title color
		let textAttributes = [NSAttributedString.Key.foregroundColor: Theme.colors.dark]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.tintColor = Theme.colors.dark
	}

	override func found(code: String) {

		viewModel.parseCode(code)
	}
}

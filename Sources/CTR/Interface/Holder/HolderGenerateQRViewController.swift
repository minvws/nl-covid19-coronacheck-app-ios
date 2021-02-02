/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class GenerateQRViewModel: Logging {

	var loggingCategory: String = "GenerateQRViewModel"

	/// The crypto manager
	var cryptoManager: CryptoManagerProtocol = CryptoManager()

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	// MARK: - Bindable properties

	@Bindable private(set) var primaryButtonTitle: String
	@Bindable private(set) var qrMessage: String?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - userIdentifier: the user identifier
	init(
		coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator
		primaryButtonTitle = "Terug naar start"
		generateQRMessage()
	}

	/// User tapped on the third button
	func primaryButtonTapped() {

		coordinator?.navigateToStart()
	}

	private func generateQRMessage() {

		



	}
}

class HolderGenerateQRViewController: BaseViewController {

	private let viewModel: GenerateQRViewModel

	let sceneView = QRCodeView()

	init(viewModel: GenerateQRViewModel) {

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

		title = "Holder Generate QR"

		viewModel.$primaryButtonTitle.binding = {

			self.sceneView.primaryTitle = $0
		}

		viewModel.$qrMessage.binding = {

			if let value = $0 {
				let image = self.generateQRCode(from: value)
				self.sceneView.qrImage = image
			}
		}
		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.primaryButtonTapped()
		}
    }

	func generateQRCode(from string: String) -> UIImage? {

		let data = string.data(using: String.Encoding.ascii)

		if let filter = CIFilter(name: "CIQRCodeGenerator") {
			filter.setValue(data, forKey: "inputMessage")
			let transform = CGAffineTransform(scaleX: 3, y: 3)

			if let output = filter.outputImage?.transformed(by: transform) {
				return UIImage(ciImage: output)
			}
		}
		return nil
	}
}

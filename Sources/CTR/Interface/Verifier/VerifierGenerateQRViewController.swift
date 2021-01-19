/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierGenerateQRViewController: BaseViewController {

	weak var coordinator: VerifierCoordinatorDelegate?

	var qrString: String = ""

	let sceneView = QRCodeView()

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
		title = "Verifier Event QR"

		sceneView.primaryTitle = "Sluiten"
		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.coordinator?.navigateToStart()
		}

		sceneView.qrImage = generateQRCode(from: qrString)
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

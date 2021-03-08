/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

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

		viewModel.$title.binding = { [weak self] in self?.title = $0 }

		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }

		viewModel.$startScanning.binding = { [weak self] in
			if $0, self?.captureSession?.isRunning == false {
				self?.captureSession.startRunning()
			}
		}
		viewModel.$torchAccessibility.binding = { [weak self] in

			guard let strongSelf = self else { return }
			strongSelf.addTorchButton(action: #selector(strongSelf.toggleTorch), accessibilityLabel: $0)
		}

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	override func found(code: String) {

		viewModel.parseQRMessage(code)
	}
}

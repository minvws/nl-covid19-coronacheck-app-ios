/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

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
		addTorchButton(action: #selector(toggleTorch), accessibilityLabel: .holderTokenScanTorchAccessibility)
	}

	override func found(code: String) {

		viewModel.parseCode(code)
	}
}

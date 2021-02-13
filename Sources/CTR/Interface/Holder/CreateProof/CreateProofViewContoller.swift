/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import MBProgressHUD

class CreateProofViewController: BaseViewController {

	private let viewModel: CreateProofViewiewModel

	let sceneView = CreateProofView()

	init(viewModel: CreateProofViewiewModel) {

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

		edgesForExtendedLayout = []

		viewModel.$title.binding = {
			self.sceneView.title = $0
		}

		viewModel.$message.binding = {
			self.sceneView.message = $0
		}

		viewModel.$buttonTitle.binding = {
			self.sceneView.primaryTitle = $0
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.buttonClick()
		}

		viewModel.$showProgress.binding = {

			if $0 {
				MBProgressHUD.showAdded(to: self.sceneView, animated: true)
				self.sceneView.primaryButton.isEnabled = false
			} else {
				MBProgressHUD.hide(for: self.sceneView, animated: true)
				self.sceneView.primaryButton.isEnabled = true
			}
		}
	}
}

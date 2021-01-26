/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MainViewController: BaseViewController {

	private let viewModel: MainViewModel
	
	let sceneView = MainView()

	init(viewModel: MainViewModel) {
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
		title = "Corona Testbewijs"
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		viewModel.$primaryButtonTitle.binding = {
			self.sceneView.primaryTitle = $0
		}

		viewModel.$secondaryButtonTitle.binding = {
			self.sceneView.secondaryTitle = $0
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.primaryButtonTapped()
		}

		sceneView.secondaryButtonTappedCommand = { [weak self] in
			self?.viewModel.secondaryButtonTapped()
		}
    }
}

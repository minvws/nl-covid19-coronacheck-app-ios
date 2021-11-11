/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MigrateEUVaccinationViewController: BaseViewController {

	private let viewModel: MigrateEUVaccinationViewModel
	private let sceneView = MigrateEUVaccinationView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: MigrateEUVaccinationViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		addBackButton(customAction: #selector(backButtonTapped))

		viewModel.$title.binding = { [weak self] title in
			self?.sceneView.title = title
		}

		viewModel.$message.binding = { [weak self] message in
			self?.sceneView.message = message
		}

		viewModel.$primaryButtonTitle.binding = { [weak self] buttonTitle in
			self?.sceneView.primaryTitle = buttonTitle
		}

		viewModel.$isLoading.binding = { [weak self] isLoading in
			self?.sceneView.isLoading = isLoading
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.primaryButtonTapped()
		}

		viewModel.$alert.binding = { [weak self] in
			self?.showAlert($0, preferredAction: $0?.okTitle)
		}
	}
	
	override var enableSwipeBack: Bool { true }

	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
	}
}

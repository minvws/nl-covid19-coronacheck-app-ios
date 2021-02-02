/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierResultViewModel {

	/// Coordination Delegate
	weak var coordinator: VerifierCoordinatorDelegate?

	// MARK: - Bindable properties

	@Bindable private(set) var primaryButtonTitle: String
	@Bindable private(set) var isValid: Bool

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - result: is this a valid test
	init(
		coordinator: VerifierCoordinatorDelegate,
		result: Bool) {

		self.coordinator = coordinator
		primaryButtonTitle = "Scan opnieuw"
		isValid = result
	}

	func dismiss() {
		
		coordinator?.dismiss()
	}
}

class VerifierResultViewController: BaseViewController {

	private let viewModel: VerifierResultViewModel

	let sceneView = ResultView()

	init(viewModel: VerifierResultViewModel) {

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
		title = "Verifier Result"

		viewModel.$primaryButtonTitle.binding = {

			self.sceneView.primaryTitle = $0
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.dismiss()
		}

		viewModel.$isValid.binding = {

			if $0 {
				self.sceneView.labelText = "V"
				self.sceneView.labelColor = Theme.colors.ok
			} else {
				self.sceneView.labelText = "X"
				self.sceneView.labelColor = Theme.colors.warning
			}
		}
	}
}

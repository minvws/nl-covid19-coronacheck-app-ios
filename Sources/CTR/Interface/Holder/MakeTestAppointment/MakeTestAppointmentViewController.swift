/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class MakeTestAppointmentViewController: BaseViewController {
	
	/// The model
	internal let viewModel: MakeTestAppointmentViewModel

	/// The view
	let sceneView = MakeTestAppointmentView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: MakeTestAppointmentViewModel) {

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

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$buttonTitle.binding = { [weak self] in self?.sceneView.buttonTitle = $0 }
		
		sceneView.button.touchUpInside(viewModel, action: #selector(MakeTestAppointmentViewModel.onTap))
	}
}

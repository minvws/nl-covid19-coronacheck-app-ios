/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

final class MakeTestAppointmentViewController: GenericViewController<MakeTestAppointmentView, MakeTestAppointmentViewModel> {
	
	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$buttonTitle.binding = { [weak self] in self?.sceneView.buttonTitle = $0 }
		
		sceneView.button.touchUpInside(viewModel, action: #selector(MakeTestAppointmentViewModel.onTap))
	}
}

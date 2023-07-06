/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

final class DCCQRDetailsViewController: GenericViewController<DCCQRDetailsView, DCCQRDetailsViewModel> {
	
	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		
		viewModel.$description.binding = { [weak self] in self?.sceneView.detailsDescription = $0 }
		
		viewModel.$details.binding = { [weak self] in self?.sceneView.details = $0 }
		
		viewModel.$dateInformation.binding = { [weak self] in self?.sceneView.dateInformation = $0 }

		viewModel.$hideForCapture.binding = { [weak self] in self?.sceneView.handleScreenCapture(shouldHide: $0) }
		
		sceneView.dosageLinkTouchedCommand = { [weak self] url in
			
			self?.viewModel.openUrl(url)
		}
	}
}

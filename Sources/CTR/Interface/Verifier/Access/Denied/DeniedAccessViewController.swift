/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class DeniedAccessViewController: GenericViewController<DeniedAccessView, DeniedAccessViewModel> {
	
	override var enableSwipeBack: Bool { false }

	// MARK: View lifecycle

	override func viewDidLoad() {

		super.viewDidLoad()
		
		addCloseButton(action: #selector(closeButtonTapped))
		
		viewModel.$accessTitle.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$primaryTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		viewModel.$secondaryTitle.binding = { [weak self] in self?.sceneView.secondaryTitle = $0 }
		
		sceneView.scanNextTappedCommand = { [weak self] in

			self?.viewModel.scanAgain()
		}
		
		sceneView.readMoreTappedCommand = { [weak self] in
			
			self?.viewModel.showMoreInformation()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		viewModel.startAutoCloseTimer()
	}
}

private extension DeniedAccessViewController {
	
	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}
}

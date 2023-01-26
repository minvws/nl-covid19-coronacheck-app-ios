/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class SendIdentitySelectionViewController: TraitWrappedGenericViewController<SendIdentitySelectionView, SendIdentitySelectionViewModel> {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.showSpinner.observe { [weak self] in self?.sceneView.shouldShowLoadingSpinner = $0 }
		viewModel.alert.observe { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)
		viewModel.viewDidAppear()
	}
}

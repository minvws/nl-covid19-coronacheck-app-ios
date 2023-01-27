/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class AuthenticationViewController: TraitWrappedGenericViewController<FetchRemoteEventsView, AuthenticationViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()

		// Binding
		viewModel.$shouldShowProgress.binding = { [weak self] in
			self?.sceneView.shouldShowLoadingSpinner = $0
		}

		viewModel.$content.binding = { [weak self] in self?.sceneView.applyContent($0) }
		viewModel.login(presentingViewController: self)
		
		addBackButton()
		
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
	}
	
	@objc func didBecomeActive() {
		
		viewModel.didBecomeActive()
	}
}

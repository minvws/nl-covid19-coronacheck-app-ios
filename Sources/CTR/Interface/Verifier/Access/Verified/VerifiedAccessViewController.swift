/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class VerifiedAccessViewController: GenericViewController<VerifiedAccessView, VerifiedAccessViewModel> {
	
	override var enableSwipeBack: Bool { false }

	override func viewDidLoad() {

		super.viewDidLoad()
		
		addCloseButton(action: #selector(closeButtonTapped))
		
		viewModel.$accessTitle.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$verifiedAccess.binding = { [weak self] in
			
			self?.sceneView.verifiedAccess = $0
			self?.navigationItem.leftBarButtonItem?.tintColor = $0.tintColor
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		viewModel.startScanAgainTimer()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		
		return viewModel.verifiedAccess.statusBarStyle
	}
}

private extension VerifiedAccessViewController {
	
	@objc func closeButtonTapped() {

		viewModel.dismiss()
	}
}

extension VerifiedAccess {
	
	var statusBarStyle: UIStatusBarStyle {
		
		if case .verified(let verificationPolicy) = self, verificationPolicy == .policy1G {
			return .lightContent
		} else {
			return .default
		}
	}
}

/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class CheckForDigidViewController: ListOptionsViewController {
	
	override func setupBackButton() {
		
		addBackButton(customAction: #selector(backButtonTapped))
	}

	@objc func backButtonTapped() {

		(viewModel as? CheckForDigidViewModel)?.goBack()
	}
}

extension CheckForDigidViewController: UINavigationControllerDelegate {
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

		if let coordinator = navigationController.topViewController?.transitionCoordinator {
			coordinator.notifyWhenInteractionChanges { [weak self] context in
				guard !context.isCancelled else { return }
				// Clean up coordinator when swiping back
				(self?.viewModel as? CheckForDigidViewModel)?.goBack()
			}
		}
	}
}

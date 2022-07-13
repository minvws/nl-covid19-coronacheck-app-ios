/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class CheckForDigidViewController: ListOptionsViewController {
	
	override func viewDidLoad() {

		super.viewDidLoad()
		
		navigationController?.delegate = self
	}
	
	override func setupBackButton() {
		
		addBackButton(customAction: #selector(backButtonTapped))
	}

	@objc func backButtonTapped() {

		(viewModel as? CheckForDigidViewModel)?.backbuttonTapped()
	}
}

extension CheckForDigidViewController: UINavigationControllerDelegate {
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

		if let coordinator = navigationController.topViewController?.transitionCoordinator {
			coordinator.notifyWhenInteractionChanges { [weak self] context in
				guard !context.isCancelled else { return }
				// We are the navigationController Delegate, we get all the swipes, even from scenes further in the flow.
				// Only propagate swipeback if we are the viewcontroller being swiped.
				guard context.viewController(forKey: .from) == self else { return }
				// Clean up coordinator when swiping back
				(self?.viewModel as? CheckForDigidViewModel)?.swipeBack()
			}
		}
	}
}

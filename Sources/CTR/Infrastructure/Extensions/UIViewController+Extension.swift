/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIViewController {
	
	/// Set up translucent navigation bar. By default, navigation bar has an opaque background
	func setupTranslucentNavigationBar() {
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.navigationBar.backgroundColor = .clear
		navigationController?.navigationBar.barTintColor = .clear
	}
	
	/// Presents a view controller as bottom sheet modal
	/// - Parameters:
	///   - viewControllerToPresent: The view controller to display over the current view controller’s content
	///   - transitioningDelegate: Initialize and hold a reference to `BottomSheetTransitioningDelegate`
	func presentBottomSheet(_ viewControllerToPresent: UIViewController, transitioningDelegate: BottomSheetTransitioningDelegate) {
		let bottomSheetViewController = BottomSheetModalViewController(childViewController: viewControllerToPresent)
		bottomSheetViewController.transitioningDelegate = transitioningDelegate
		bottomSheetViewController.modalPresentationStyle = .custom
		bottomSheetViewController.modalPresentationCapturesStatusBarAppearance = true
		present(bottomSheetViewController, animated: true)
	}
}

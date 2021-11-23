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
		if #available(iOS 15.0, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithTransparentBackground()
			navigationController?.navigationBar.standardAppearance = appearance
			navigationController?.navigationBar.scrollEdgeAppearance = appearance
		} else {
			navigationController?.navigationBar.isTranslucent = true
			navigationController?.navigationBar.backgroundColor = .clear
			navigationController?.navigationBar.barTintColor = .clear
		}
	}
	
	func overrideNavigationBarTitleColor(with color: UIColor) {
		if #available(iOS 15.0, *) {
			navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: color]
			navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: color]
		}
	}
	
	func restoreNavigationBarTitleColor() {
		if #available(iOS 15.0, *) {
			navigationController?.navigationBar.standardAppearance.titleTextAttributes = [:]
			navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [:]
		}
	}
	
	/// Presents a view controller as bottom sheet modal
	/// - Parameters:
	///   - viewControllerToPresent: The view controller to display over the current view controller’s content
	func presentBottomSheet(_ viewControllerToPresent: UIViewController) {
		let bottomSheetViewController = BottomSheetModalViewController(childViewController: viewControllerToPresent)
		bottomSheetViewController.transitioningDelegate = BottomSheetTransitioningDelegate.default
		bottomSheetViewController.modalPresentationStyle = .custom
		bottomSheetViewController.modalPresentationCapturesStatusBarAppearance = true
		present(bottomSheetViewController, animated: true)
	}
}

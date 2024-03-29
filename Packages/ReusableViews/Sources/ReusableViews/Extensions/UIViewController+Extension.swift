/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Resources

extension UIViewController {
	
	/// Set up translucent navigation bar. By default, navigation bar has an opaque background
	public func setupTranslucentNavigationBar() {
		let titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: C.black()!,
			NSAttributedString.Key.font: Fonts.bodyMontserratFixed
		]
		let largeTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: C.black()!,
			NSAttributedString.Key.font: Fonts.title1Montserrat
		]
		
		if #available(iOS 15.0, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithTransparentBackground()
			appearance.titleTextAttributes = titleTextAttributes
			appearance.largeTitleTextAttributes = largeTitleTextAttributes
			appearance.shadowColor = .clear
			navigationController?.navigationBar.standardAppearance = appearance
			navigationController?.navigationBar.compactAppearance = appearance
			navigationController?.navigationBar.scrollEdgeAppearance = appearance
		} else {
			navigationController?.navigationBar.isTranslucent = true
			navigationController?.navigationBar.backgroundColor = .clear
			navigationController?.navigationBar.barTintColor = .clear
		}
	}
	
	/// Set the navigation bar's title color. For use with iOS 15.
	/// - Parameters:
	///   - color: The color to apply
	public func overrideNavigationBarTitleColor(with color: UIColor) {
		
		let titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: color,
			NSAttributedString.Key.font: Fonts.bodyMontserratFixed
		]
		navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
		navigationController?.navigationBar.tintColor = color
		
		if #available(iOS 15.0, *) {
			navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: color]
			navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: color]
		}
	}
	
	/// Presents a view controller as bottom sheet modal
	/// - Parameters:
	///   - viewControllerToPresent: The view controller to display over the current view controller’s content
	public func presentBottomSheet(_ viewControllerToPresent: UIViewController) {
		let bottomSheetViewController = BottomSheetModalViewController(childViewController: viewControllerToPresent)
		bottomSheetViewController.transitioningDelegate = BottomSheetTransitioningDelegate.default
		bottomSheetViewController.modalPresentationStyle = .custom
		bottomSheetViewController.modalPresentationCapturesStatusBarAppearance = true
		present(bottomSheetViewController, animated: true)
	}
		
	public func addBackButton(customAction: Selector? = nil) {
		
		var action = #selector(onBack)
		if let customAction {
			action = customAction
		}
		
		let config = UIBarButtonItem.Configuration(
			target: self,
			action: action,
			content: .image(I.backArrow()),
			accessibilityIdentifier: "BackButton",
			accessibilityLabel: L.generalBack()
		)
		navigationItem.leftBarButtonItem = .create(config)
	}
	
	@objc open func onBack() {
		navigationController?.popViewController(animated: true)
	}
}

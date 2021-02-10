/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// A customized version of the SidePanelController
class CustomSidePanelController: SidePanelController {

	/// The width of the panel, 75% of the screen
	override var sidePanelWidth: CGFloat {
		get { return 0.75 * UIScreen.main.bounds.width }
		set { super.sidePanelWidth = newValue }
	}

	/// The open and close animation speed, 0.3 seconds
	override var animationSpeed: Double {
		get { return 0.3 }
		set { super.animationSpeed = newValue }
	}

	/// Flag to indicate if menu is open or not
	fileprivate var menuIsOpen = false

	/// Added hamburger icon with accessibility
	override func updateSelectedViewcontroller() {

		let mainViewController = (selectedViewController as? UINavigationController)?.topViewController ?? selectedViewController
		if let navItem = mainViewController?.navigationItem,
			navItem.leftBarButtonItem == nil {
			let hamburger = UIImage.hamburger
			let button = UIBarButtonItem(
				image: hamburger,
				style: .plain,
				target: self,
				action: #selector(showSidePanel))
			navItem.leftBarButtonItem = button
            navItem.leftBarButtonItem?.accessibilityIdentifier = "OpenMenuButton"
			navItem.leftBarButtonItem?.accessibilityLabel = .close
		}
		super.updateSelectedViewcontroller()
	}

	/// Added extra check to prevent opening menu with a slide left when the menu is closed
	///
	/// - Parameter panGestureRecognizer: UIPanGestureRecognizer
	@objc override func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {

		guard menuIsOpen else {
			return
		}
		super.handlePan(panGestureRecognizer)
	}

	/// Menu is closed when the panel hides
	@objc override func hideSidePanel() {

		super.hideSidePanel()
        menuIsOpen = false

        view.gestureRecognizers?.forEach({ gestureRecognizer in
            gestureRecognizer.isEnabled = false
        })
        
		if let mainViewController = (selectedViewController as? UINavigationController)?.topViewController ?? selectedViewController {
			UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: mainViewController)
		}
		sidePanelView.accessibilityViewIsModal = false
	}

	/// Menu is open when the panel shows.
	@objc override func showSidePanel() {

		super.showSidePanel()
		self.menuIsOpen = true
        
        view.gestureRecognizers?.forEach({ gestureRecognizer in
            gestureRecognizer.isEnabled = true
        })
        
		UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: sideController)
		sidePanelView.accessibilityViewIsModal = true
	}
}

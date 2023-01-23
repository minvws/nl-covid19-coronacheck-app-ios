/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

class PagedAnnouncementViewController: GenericViewController<PagedAnnouncementView, PagedAnnouncementViewModel> {
	
	/// The page controller
	private let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	
	/// Disable swiping to launch screen
	override var enableSwipeBack: Bool { false }
	
	var showsBackButton: Bool {
		backButtonAction != nil
	}
	let backButtonAction: (() -> Void)?
	let allowsPreviousPageButton: Bool
	let allowsCloseButton: Bool
	let allowsNextPageButton: Bool
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: PagedAnnouncementViewModel, allowsPreviousPageButton: Bool, allowsCloseButton: Bool, allowsNextPageButton: Bool, backButtonAction: (() -> Void)? = nil) {
		
		self.backButtonAction = backButtonAction
		self.allowsPreviousPageButton = allowsPreviousPageButton
		self.allowsCloseButton = allowsCloseButton
		self.allowsNextPageButton = allowsNextPageButton
		
		super.init(
			sceneView: PagedAnnouncementView(shouldShowWithVWSRibbon: viewModel.shouldShowWithVWSRibbon),
			viewModel: viewModel
		)
	}
	
	private var backButton: UIBarButtonItem?
	private var previousPageButton: UIBarButtonItem?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		setupPageController()
		
		viewModel.$pages.binding = { [weak self] in
			guard let self else { return }
			
			self.pageViewController.pages = $0.compactMap { page in
				guard let viewController = self.viewModel.getStep(page) as? PagedAnnouncementItemViewController else { return nil }
				self.sceneView.updateFooterView(mainScrollView: viewController.sceneView.scrollView)
				viewController.delegate = self
				return viewController
			}
			
			self.sceneView.pageControl.numberOfPages = $0.count
			self.updateFooterView(for: 0)
		}
		
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		
		viewModel.$enabled.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }
 
		if allowsPreviousPageButton || showsBackButton {
			if allowsPreviousPageButton {
				setupPreviousPageButton()
			}
			if showsBackButton {
				setupBackButton()
			}

			updateLeftNavbarButton(forPageIndex: 0)
			
			setupTranslucentNavigationBar()
			navigationController?.isNavigationBarHidden = false
		} else if allowsCloseButton {
			addCloseButton(action: #selector(closeButtonTapped))
			setupTranslucentNavigationBar()
			navigationController?.isNavigationBarHidden = false
		} else {
			navigationController?.isNavigationBarHidden = true
		}
		
		sceneView.primaryButton.isHidden = !allowsNextPageButton
	}
	
	/// Create a custom previous-page button so we can catch the tap on the back button.
	private func setupPreviousPageButton() {

		// Create a button with a back arrow
		let config = UIBarButtonItem.Configuration(target: self,
												   action: #selector(previousPageButtonTapped),
												   content: .image(I.backArrow()),
												   accessibilityIdentifier: "BackButton",
												   accessibilityLabel: L.generalBack())
		previousPageButton = .create(config)
	}
	
	private func setupBackButton() {

		// Create a button with a back arrow
		let config = UIBarButtonItem.Configuration(target: self,
												   action: #selector(backButtonTapped),
												   content: .image(I.backArrow()),
												   accessibilityIdentifier: "BackButton",
												   accessibilityLabel: L.generalBack())
		navigationItem.backBarButtonItem = .create(config)
	}
	
	@objc func previousPageButtonTapped() {
		
		// Move to the previous page
		pageViewController.previousPage()
		sceneView.primaryButton.isEnabled = true
	}
	
	@objc func backButtonTapped() {
		
		backButtonAction?()
	}
	
	@objc func closeButtonTapped() {
		
		viewModel.closeButtonTapped()
	}
	
	/// Setup the page controller
	private func setupPageController() {
		
		pageViewController.pageViewControllerDelegate = self
		pageViewController.view.backgroundColor = .clear
		
		pageViewController.view.frame = sceneView.containerView.frame
		addChild(pageViewController)
		pageViewController.didMove(toParent: self)
		sceneView.containerView.addSubview(pageViewController.view)
		sceneView.pageControl.delegate = self
		
		// Disable for first page to announce ribbon view
		pageViewController.isAccessibilityPageAnnouncementEnabled = false
	}
	
	/// User tapped on the button
	@objc func primaryButtonTapped() {
		
		if pageViewController.isLastPage {
			// We tapped on the last page
			viewModel.finish()
		} else {
			// Move to the next page
			pageViewController.nextPage()
		}
	}
	
	func updateLeftNavbarButton(forPageIndex index: Int) {
		
		if index == 0 && showsBackButton {
			navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
		} else {
			navigationItem.leftBarButtonItem = index > 0 ? previousPageButton : nil
		}
	}
}

private extension PagedAnnouncementViewController {
	
	func updateFooterView(for pageIndex: Int) {
		guard let pages = pageViewController.pages, !pages.isEmpty else { return }
		guard let viewController = pages[pageIndex] as? PagedAnnouncementItemViewController else {
			assertionFailure("View controller should be of type PagedAnnouncementItemViewController")
			return
		}
		sceneView.updateFooterView(mainScrollView: viewController.sceneView.scrollView)
		
		sceneView.primaryButton.setTitle(viewModel.primaryButtonTitle(forStep: pageIndex), for: .normal)
	}
}

// MARK: - PageViewControllerDelegate

extension PagedAnnouncementViewController: PageViewControllerDelegate {
	
	func pageViewController(_ pageViewController: PageViewController, didSwipeToPendingViewControllerAt index: Int) {
		sceneView.pageControl.update(for: index)
		updateLeftNavbarButton(forPageIndex: index)
		updateFooterView(for: index)
		
		// Announce ribbon view when going back to the first page
		if index == 0 {
			sceneView.ribbonView.isAccessibilityElement = true
			pageViewController.isAccessibilityPageAnnouncementEnabled = false
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				UIAccessibility.post(notification: .screenChanged, argument: self.sceneView.ribbonView)
			}
		} else {
			sceneView.ribbonView.isAccessibilityElement = false
			pageViewController.isAccessibilityPageAnnouncementEnabled = true
		}
	}
}

// MARK: - OnboardingPageViewControllerDelegate

extension PagedAnnouncementViewController: PagedAnnouncementItemViewControllerDelegate {
	
	/// Enables swipe to navigate behaviour for assistive technologies
	func onAccessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
		if direction == .right {
			previousPageButtonTapped()
			return true
		} else if direction == .left {
			primaryButtonTapped()
			return true
		}
		return false
	}
}

// MARK: - PageControlDelegate

extension PagedAnnouncementViewController: PageControlDelegate {
	
	func pageControl(didChangeToPageIndex currentPageIndex: Int, previousPageIndex: Int) {
		if currentPageIndex > previousPageIndex {
			pageViewController.nextPage()
		} else {
			pageViewController.previousPage()
		}
	}
}

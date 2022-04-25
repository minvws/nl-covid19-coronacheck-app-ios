/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class PagedAnnouncementViewController: BaseViewController {
	
	/// The model
	private let viewModel: PagedAnnouncementViewModel
	
	/// The view
	lazy var sceneView = PagedAnnouncementView(shouldShowWithVWSRibbon: viewModel.shouldShowWithVWSRibbon)
	
	/// The page controller
	private let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	
	/// Disable swiping to launch screen
	override var enableSwipeBack: Bool { false }
	
	let allowsBackButton: Bool
	let allowsCloseButton: Bool
	let allowsNextButton: Bool
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: PagedAnnouncementViewModel, allowsBackButton: Bool, allowsCloseButton: Bool, allowsNextButton: Bool) {
		
		self.viewModel = viewModel
		self.allowsBackButton = allowsBackButton
		self.allowsCloseButton = allowsCloseButton
		self.allowsNextButton = allowsNextButton
		
		super.init(nibName: nil, bundle: nil)
	}
	
	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: View lifecycle
	override func loadView() {
		
		view = sceneView
	}
	
	// the back button
	private var backButton: UIBarButtonItem?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		setupPageController()
		
		viewModel.$pages.binding = { [weak self] in
			guard let self = self else { return }
			
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
		
		if allowsBackButton {
			setupBackButton()
			setupTranslucentNavigationBar()
			navigationController?.isNavigationBarHidden = false
		} else if allowsCloseButton {
			addCloseButton(action: #selector(closeButtonTapped))
			setupTranslucentNavigationBar()
			navigationController?.isNavigationBarHidden = false
		} else {
			navigationController?.isNavigationBarHidden = true
		}
		
		sceneView.primaryButton.isHidden = !allowsNextButton
	}
	
	/// Create a custom back button so we can catch the tap on the back button.
	private func setupBackButton() {

		// Create a button with a back arrow
		let config = UIBarButtonItem.Configuration(target: self,
												   action: #selector(backbuttonTapped),
												   content: .image(I.backArrow()),
												   accessibilityIdentifier: "BackButton",
												   accessibilityLabel: L.generalBack())
		backButton = .create(config)
	}
	
	@objc func backbuttonTapped() {
		
		// Move to the previous page
		pageViewController.previousPage()
		sceneView.primaryButton.isEnabled = true
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
		navigationItem.leftBarButtonItem = index > 0 ? backButton: nil
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
            backbuttonTapped()
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
	
	func pageControl(_ pageControl: PageControl, didChangeToPageIndex currentPageIndex: Int, previousPageIndex: Int) {
		if currentPageIndex > previousPageIndex {
			pageViewController.nextPage()
		} else {
			pageViewController.previousPage()
		}
	}
}

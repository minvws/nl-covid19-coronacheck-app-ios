/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingViewController: BaseViewController {
	
	/// The model
	private let viewModel: OnboardingViewModel
	
	/// The view
	let sceneView = OnboardingView()
	
	/// The page controller
	private let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	
	/// Disable swiping to launch screen
	override var enableSwipeBack: Bool { false }
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: OnboardingViewModel) {
		
		self.viewModel = viewModel
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
		
		setupTranslucentNavigationBar()
		
		setupPageController()
		viewModel.$pages.binding = { [weak self] in

			guard let self = self else {
				return
			}
			
			self.pageViewController.pages = $0.compactMap { page in
				guard let onboardingPageViewController = self.viewModel.getOnboardingStep(page) as? OnboardingPageViewController else { return nil }
				onboardingPageViewController.delegate = self
				return onboardingPageViewController
			}
			
			self.sceneView.pageControl.numberOfPages = $0.count
			self.updateFooterView(for: 0)
		}
		
		sceneView.primaryButton.setTitle(L.generalNext(), for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		
		viewModel.$enabled.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }
		
		setupBackButton()
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
	
	/// The user tapped on the back button
	@objc func backbuttonTapped() {
		
		// Move to the previous page
		pageViewController.previousPage()
		sceneView.primaryButton.isEnabled = true
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
	}
	
	/// User tapped on the button
	@objc func primaryButtonTapped() {
		
		if pageViewController.isLastPage {
			// We tapped on the last page
			viewModel.finishOnboarding()
		} else {
			// Move to the next page
			pageViewController.nextPage()
		}
	}
}

private extension OnboardingViewController {
	
	func updateFooterView(for pageIndex: Int) {
		guard let pages = pageViewController.pages, !pages.isEmpty else { return }
		guard let viewController = pages[pageIndex] as? OnboardingPageViewController else {
			assertionFailure("View controller should be of type OnboardingPageViewController")
			return
		}
		sceneView.updateFooterView(mainScrollView: viewController.sceneView.scrollView)
	}
}

// MARK: - PageViewControllerDelegate

extension OnboardingViewController: PageViewControllerDelegate {
	
	func pageViewController(_ pageViewController: PageViewController, didSwipeToPendingViewControllerAt index: Int) {
		sceneView.pageControl.update(for: index)
        sceneView.ribbonView.isAccessibilityElement = index == 0
		navigationItem.leftBarButtonItem = index > 0 ? backButton: nil
		updateFooterView(for: index)
	}
}

// MARK: - OnboardingPageViewControllerDelegate

extension OnboardingViewController: OnboardingPageViewControllerDelegate {
    
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

extension OnboardingViewController: PageControlDelegate {
	
	func pageControl(_ pageControl: PageControl, didChangeToPageIndex currentPageIndex: Int, previousPageIndex: Int) {
		if currentPageIndex > previousPageIndex {
			pageViewController.nextPage()
		} else {
			pageViewController.previousPage()
		}
	}
}

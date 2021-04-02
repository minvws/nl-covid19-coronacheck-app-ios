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
	private var pageViewController: UIPageViewController?
	
	/// The current index of the visbile page
	var currentIndex: Int? {
		didSet {
			if let index = currentIndex {
				sceneView.pageControl.currentPage = index
				navigationItem.leftBarButtonItem = index > 0 ? backButton: nil
			}
		}
	}
	
	/// the possibile next index of the page
	private var pendingIndex: Int?
	
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
	
	/// the onboarding viewcontrollers
	private var viewControllers = [UIViewController]()
	
	// the back button
	private var backButton: UIBarButtonItem?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		setupPageController()
		viewModel.$pages.binding = { [weak self] in

			guard let strongSelf = self else {
				return
			}

			strongSelf.currentIndex = 0
			for page in $0 {
				strongSelf.viewControllers.append(strongSelf.viewModel.getOnboardingStep(page))
			}
			if let firstVC = strongSelf.viewControllers.first {
				strongSelf.pageViewController?.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
				strongSelf.pageViewController?.didMove(toParent: self)
			}
			strongSelf.sceneView.pageControl.numberOfPages = $0.count
			strongSelf.sceneView.pageControl.currentPage = 0
		}
		
		sceneView.primaryButton.setTitle(.next, for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		
		viewModel.$enabled.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }
		
		setupBackButton()
	}
	
	/// Create a custom back button so we can catch the tapped on the back button.
	private func setupBackButton() {
		
		navigationItem.hidesBackButton = true
		
		let button = UIButton(type: .custom)
		button.setTitle(.previous, for: .normal)
		button.setTitleColor(Theme.colors.dark, for: .normal)
		button.setTitleColor(Theme.colors.gray, for: .highlighted)
		button.titleLabel?.font = Theme.fonts.bodyBoldFixed
		button.setImage(.backArrow, for: .normal)
		// Add a little spacing between the image and the title, shift the tilte 5 px right
		button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		// Increase the hit area, move the button 5 px to the left
		button.contentEdgeInsets = UIEdgeInsets(top: 10, left: -5, bottom: 10, right: 10)
		button.addTarget(self, action: #selector(backbuttonTapped), for: .touchUpInside)
		button.accessibilityLabel = .back
		
		backButton = UIBarButtonItem(customView: button)
	}
	
	/// The user tapped on the back button
	@objc func backbuttonTapped() {
		
		if var index = currentIndex, index > 0 {
			// Move to the previous page
			index -= 1
			let nextVC = viewControllers[index]
			self.pageViewController?.setViewControllers([nextVC], direction: .reverse, animated: true, completion: nil)
			currentIndex = index
			self.sceneView.primaryButton.isEnabled = true
		}
	}
	
	/// Setup the page controller
	private func setupPageController() {
		
		let pageCtrl = UIPageViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal,
			options: nil
		)
		self.pageViewController = pageCtrl
		pageCtrl.dataSource = self
		pageCtrl.delegate = self
		pageCtrl.view.backgroundColor = .clear
		
		pageCtrl.view.frame = sceneView.containerView.frame
		sceneView.containerView.addSubview(pageCtrl.view)
		self.addChild(pageCtrl)
		pageCtrl.didMove(toParent: self)
	}
	
	/// User tapped on the button
	@objc func primaryButtonTapped() {
		
		if var index = currentIndex {
			
			if index == viewControllers.count - 1 {
				// We tapped on the last page
				viewModel.finishOnboarding()
			} else {
				// Move to the next page
				index += 1
				let nextVC = viewControllers[index]
				self.pageViewController?.setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
				currentIndex = index
			}
		}
	}
}

// MARK: - UIPageViewControllerDataSource & UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	
	/// Get the view controller before the current
	/// - Parameters:
	///   - pageViewController: the page view controller
	///   - viewController: the current view controller
	/// - Returns: The previous view controller or nil if there is none.
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController) -> UIViewController? {
		
		guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
			return nil
		}
		
		currentIndex = viewControllerIndex
		if currentIndex == 0 {
			return nil
		}
		let previousIndex = abs((viewControllerIndex - 1) % viewControllers.count)
		return viewControllers[previousIndex]
	}
	/// Get the view controller after the current
	/// - Parameters:
	///   - pageViewController: the page view controller
	///   - viewController: the current view controller
	/// - Returns: The next view controller or nil if there is none.
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController) -> UIViewController? {
		
		guard let viewControllerIndex = viewControllers.firstIndex(of: viewController) else {
			return nil
		}
		
		currentIndex = viewControllerIndex
		if viewControllerIndex == viewControllers.count - 1 {
			return nil
		}
		
		let nextIndex = abs((viewControllerIndex + 1) % viewControllers.count)
		return viewControllers[nextIndex]
	}
	
	/// The page view controller will move to the another view controller
	/// - Parameters:
	///   - pageViewController: the page view controller
	///   - pendingViewControllers: the next view controller
	func pageViewController(
		_ pageViewController: UIPageViewController,
		willTransitionTo pendingViewControllers: [UIViewController]) {
		
		if let first = pendingViewControllers.first, let viewControllerIndex = viewControllers.firstIndex(of: first) {
			
			pendingIndex = viewControllerIndex
		}
	}
	
	/// The page view controller has moved the another view controller
	/// - Parameters:
	///   - pageViewController: the page view controller
	///   - finished: True if the animation is finished
	///   - previousViewControllers: the previous view controller
	///   - completed: True if the transistion is finished
	func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool) {
		
		if completed {
			currentIndex = pendingIndex
		}
	}
}

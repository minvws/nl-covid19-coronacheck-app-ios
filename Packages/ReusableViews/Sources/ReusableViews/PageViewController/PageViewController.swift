/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

public protocol PageViewControllerDelegate: AnyObject {
	
	func pageViewController(_ pageViewController: PageViewController, didSwipeToPendingViewControllerAt index: Int)
}

final public class PageViewController: UIPageViewController {
	
	public weak var pageViewControllerDelegate: PageViewControllerDelegate?
	private var inProgress = false
	public var pages: [UIViewController]? {
		didSet {
			guard let pages = pages, let initialViewController = pages.first else { return }
			setViewControllers([initialViewController], direction: .forward, animated: false, completion: nil)
		}
	}
	public var isLastPage: Bool {
		guard let pages = pages else { return false }
		return pages.count - 1 == currentIndex
	}
	public var isAccessibilityPageAnnouncementEnabled = true
	
	public private(set) var currentIndex = 0 {
		didSet {
			pageViewControllerDelegate?.pageViewController(self, didSwipeToPendingViewControllerAt: currentIndex)
		}
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource = self
		delegate = self
	}
	
	public override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {

		guard !inProgress else { return }
		inProgress = true

		super.setViewControllers(viewControllers, direction: direction, animated: animated) { completed in

			self.inProgress = false
			completion?(completed)

			guard self.isAccessibilityPageAnnouncementEnabled else { return }
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				if let view = viewControllers?.first?.view {
					UIAccessibility.post(notification: .screenChanged, argument: view)
				}
			}
		}
	}
	
	public func nextPage() {
		guard let currentViewController = viewControllers?.first else { return }
		guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else { return }
		guard !inProgress else { return }
		currentIndex += 1
		setViewControllers([nextViewController], direction: .forward, animated: true)
	}
	
	public func previousPage() {
		guard let currentViewController = viewControllers?.first else { return }
		guard let previousViewController = dataSource?.pageViewController(self, viewControllerBefore: currentViewController) else { return }
		guard !inProgress else { return }
		currentIndex -= 1
		setViewControllers([previousViewController], direction: .reverse, animated: true)
	}

	public func startAtIndex(_ index: Int) {
		guard let pages = pages, pages.count > index else { return }
		guard !inProgress else { return }
		setViewControllers([pages[index]], direction: .forward, animated: false, completion: nil)
		currentIndex = index
	}
}

extension PageViewController: UIPageViewControllerDataSource {
	
	public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let pages = pages, let index = pages.firstIndex(of: viewController) else { return nil }
		let updatedIndex = index - 1
		guard updatedIndex >= 0 else { return nil }
		return pages[updatedIndex]
	}
	
	public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let pages = pages, let index = pages.firstIndex(of: viewController) else { return nil }
		let updatedIndex = index + 1
		guard updatedIndex < pages.count else { return nil }
		return pages[updatedIndex]
	}
}

extension PageViewController: UIPageViewControllerDelegate {
	
	public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		guard completed else { return }
		guard let pages = pages, let currentViewController = viewControllers?.first, let index = pages.firstIndex(of: currentViewController) else { return }
		currentIndex = index
	}
}

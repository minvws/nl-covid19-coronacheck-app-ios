/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanInstructionsViewController: BaseViewController {
	let sceneView = ScanInstructionsView()

	private let viewModel: ScanInstructionsViewModel
	private let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

	private let skipButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setTitle(L.verifierScaninstructionsNavigationSkipbuttonTitle(), for: .normal)
		button.setTitleColor(Theme.colors.primary, for: .normal)
		button.titleLabel?.font = Theme.fonts.bodyBoldFixed
		button.translatesAutoresizingMaskIntoConstraints = false

		// Add a little spacing between the image and the title, shift the title 5 px right
		button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
		// Increase the hit area, move the button 5 px to the left
		button.contentEdgeInsets = UIEdgeInsets(top: 10, left: -5, bottom: 10, right: 10)

		// Make sure the text won't be truncated if the user opts for bold texts
		button.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ScanInstructionsViewModel) {
		
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
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		setupTranslucentNavigationBar()
		
		setupPageController()

		viewModel.$pages.binding = { [weak self] in

			guard let self = self else {
				return
			}
			
			self.pageViewController.pages = $0.enumerated().compactMap { index, page in
				let viewController = self.viewModel.scanInstructionsViewController(forPage: page)
				viewController.delegate = self
				viewController.sceneView.stepSubheading = L.verifierScaninstructionsStepTitle(String(index + 1))
				
				return viewController
			}
			self.sceneView.pageControl.numberOfPages = $0.count
			self.updateFooterView(for: 0)
		}

		viewModel.$shouldShowSkipButton.binding = { [weak self] shouldShowSkipButton in
			self?.skipButton.isHidden = !shouldShowSkipButton
		}

		viewModel.$nextButtonTitle.binding = { [weak self] nextButtonTitle in
			self?.sceneView.primaryButton.setTitle(nextButtonTitle, for: .normal)
		}

		title = L.verifierScaninstructionsNavigationTitle()
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		
		setupBackButton()
		setupSkipButton()
	}

	/// Create a custom back button so we can catch the tap on the back button.
	private func setupBackButton() {

		let config = UIBarButtonItem.Configuration(target: self,
												   action: #selector(backButtonTapped),
												   content: .image(I.backArrow()),
												   accessibilityIdentifier: "BackButton",
												   accessibilityLabel: L.generalBack())
		navigationItem.leftBarButtonItem = .create(config)
	}

	/// Create a custom skip button
	private func setupSkipButton() {

		skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
		if #available(iOS 13.0, *) {
			skipButton.addInteraction(UILargeContentViewerInteraction())
			skipButton.showsLargeContentViewer = true
		}
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: skipButton)
	}

	@objc func backButtonTapped() {

		// Move to the previous page
		guard pageViewController.currentIndex > 0 else {
			viewModel.userTappedBackOnFirstPage()
			return
		}
		pageViewController.previousPage()
	}

	@objc func skipButtonTapped() {
		
		viewModel.finishScanInstructions()
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
			viewModel.finishScanInstructions()
		} else {
			// Move to the next page
			pageViewController.nextPage()
		}
	}
}

private extension ScanInstructionsViewController {
	
	func updateFooterView(for pageIndex: Int) {
		guard let pages = pageViewController.pages, !pages.isEmpty else { return }
		guard let viewController = pages[pageIndex] as? ScanInstructionsPageViewController else {
			assertionFailure("View controller should be of type ScanInstructionsPageViewController")
			return
		}
		sceneView.updateFooterView(mainScrollView: viewController.sceneView.scrollView)
	}
}

// MARK: - PageViewControllerDelegate

extension ScanInstructionsViewController: PageViewControllerDelegate {
	
	func pageViewController(_ pageViewController: PageViewController, didSwipeToPendingViewControllerAt index: Int) {
		sceneView.pageControl.update(for: index)
		viewModel.userDidChangeCurrentPage(toPageIndex: index)
		updateFooterView(for: index)
	}
}

// MARK: - ScanInstructionsPageViewControllerDelegate

extension ScanInstructionsViewController: ScanInstructionsPageViewControllerDelegate {
    
    /// Enables swipe to navigate behaviour for assistive technologies
    func onAccessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        if direction == .right {
            backButtonTapped()
            return true
        } else if direction == .left {
            primaryButtonTapped()
            return true
        }
        return false
    }
}

// MARK: - PageControlDelegate

extension ScanInstructionsViewController: PageControlDelegate {
	
	func pageControl(_ pageControl: PageControl, didChangeToPageIndex currentPageIndex: Int, previousPageIndex: Int) {
		if currentPageIndex > previousPageIndex {
			pageViewController.nextPage()
		} else {
			pageViewController.previousPage()
		}
	}
}

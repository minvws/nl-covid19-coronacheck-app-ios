/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class ShowQRViewController: BaseViewController {

	let sceneView = ShowQRView()

	private let viewModel: ShowQRViewModel
	private let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	var previousOrientation: UIInterfaceOrientation?

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ShowQRViewModel) {

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

		sceneView.backgroundColor = .red // .white

		setupPageController()
		setupPages()
		setupBinding()
		addBackButton()
	}

	private func setupBinding() {

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$infoButtonAccessibility.binding = { [weak self] in
			self?.addInfoButton(action: #selector(self?.informationButtonTapped), accessibilityLabel: $0 ?? "")
		}
		viewModel.$showInternationalAnimation.binding = { [weak self] in
			if $0 {
				self?.sceneView.setupForInternational()
			}
		}
		viewModel.$thirdPartyTicketAppButtonTitle.binding = { [weak self] in self?.sceneView.returnToThirdPartyAppButtonTitle = $0 }
		sceneView.didTapThirdPartyAppButtonCommand = { [viewModel] in viewModel.didTapThirdPartyAppButton() }

		sceneView.didTapPreviousButtonCommand = { [weak self] in self?.pageViewController.previousPage() }
		sceneView.didTapNextButtonCommand = { [weak self] in self?.pageViewController.nextPage() }
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		sceneView.play()
		previousOrientation = OrientationUtility.currentOrientation()
		OrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
	}

	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)
		OrientationUtility.lockOrientation(.all, andRotateTo: previousOrientation ?? .portrait)
	}
}

// MARK: Details

extension ShowQRViewController {

	/// Add an information button to the navigation bar.
	/// - Parameters:
	///   - action: The action when the users taps the information button
	///   - accessibilityLabel: The label for Voice Over
	func addInfoButton(
		action: Selector,
		accessibilityLabel: String) {

			let config = UIBarButtonItem.Configuration(
				target: self,
				action: action,
				text: L.holderShowqrDetails(),
				tintColor: Theme.colors.iosBlue,
				accessibilityIdentifier: "InformationButton",
				accessibilityLabel: accessibilityLabel
			)
			navigationItem.rightBarButtonItem = .create(config)
		}

	@objc func informationButtonTapped() {

		viewModel.showMoreInformation()
	}
}

// MARK: PageController

extension ShowQRViewController {

	private func setupPages() {

		viewModel.$items.binding = { [weak self] in

			guard let self = self else {
				return
			}

			self.pageViewController.pages = $0.compactMap { item in
				return self.viewModel.showQRItemViewController(forItem: item)
			}
			self.sceneView.pageControl.numberOfPages = $0.count
			self.sceneView.pageControl.currentPage = 0
			self.updateControlVisibility()
		}
	}

	/// Setup the page controller
	private func setupPageController() {

		pageViewController.pageViewControllerDelegate = self
		pageViewController.view.backgroundColor = .blue // .clear

		pageViewController.view.frame = sceneView.containerView.frame
		sceneView.containerView.addSubview(pageViewController.view)
		addChild(pageViewController)
		pageViewController.didMove(toParent: self)
		sceneView.pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
	}

	/// User tapped on the page control
	@objc func pageControlValueChanged(_ pageControl: UIPageControl) {

		if pageControl.currentPage > pageViewController.currentIndex {
			pageViewController.nextPage()
		} else {
			pageViewController.previousPage()
		}
	}

	func updateControlVisibility() {

		sceneView.nextButton.isHidden = pageViewController.isLastPage
		sceneView.previousButton.isHidden = pageViewController.currentIndex == 0
	}
}

// MARK: - PageViewControllerDelegate

extension ShowQRViewController: PageViewControllerDelegate {

	func pageViewController(_ pageViewController: PageViewController, didSwipeToPendingViewControllerAt index: Int) {
		sceneView.pageControl.currentPage = index
		viewModel.userDidChangeCurrentPage(toPageIndex: index)
		updateControlVisibility()
	}
}

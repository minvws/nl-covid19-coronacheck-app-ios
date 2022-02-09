/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class NewFeaturesViewController: BaseViewController {
	
	/// The model
	private let viewModel: NewFeaturesViewModel
	
	/// The view
	let sceneView = NewFeaturesView()
	
	/// The page controller
	private let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: NewFeaturesViewModel) {
		
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
		
		setupPageController()
		viewModel.$pages.binding = { [weak self] in

			guard let self = self else {
				return
			}
			
			self.pageViewController.pages = $0.compactMap { page in
				guard let viewController = self.viewModel.getNewFeatureStep(page) as? NewFeaturesItemViewController else { return nil }
				self.sceneView.updateFooterView(mainScrollView: viewController.sceneView.scrollView)
				return viewController
			}
		}
		
		sceneView.primaryButton.setTitle(L.generalNext(), for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	/// Setup the page controller
	private func setupPageController() {
		
		pageViewController.view.backgroundColor = .clear
		
		pageViewController.view.frame = sceneView.containerView.frame
		addChild(pageViewController)
		pageViewController.didMove(toParent: self)
		sceneView.containerView.addSubview(pageViewController.view)
	}
	
	/// User tapped on the button
	@objc func primaryButtonTapped() {
		
		if pageViewController.isLastPage {
			// We tapped on the last page
			viewModel.finish(.updateItemViewed)
		} else {
			// Move to the next page
			pageViewController.nextPage()
		}
	}
}

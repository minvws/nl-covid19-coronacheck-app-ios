/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class ForcedInformationViewController: BaseViewController {
	
	/// The model
	private let viewModel: ForcedInformationViewModel
	
	/// The view
	let sceneView = ForcedInformationView()
	
	/// The page controller
	private let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ForcedInformationViewModel) {
		
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
				guard let forcedInformationPageViewController = self.viewModel.getForcedInformatioStep(page) as? ForcedInformationPageViewController else { return nil }
				return forcedInformationPageViewController
			}
		}
		
		sceneView.primaryButton.setTitle(.next, for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}
	
	/// Setup the page controller
	private func setupPageController() {
		
		pageViewController.view.backgroundColor = .clear
		
		pageViewController.view.frame = sceneView.containerView.frame
		sceneView.containerView.addSubview(pageViewController.view)
		addChild(pageViewController)
		pageViewController.didMove(toParent: self)
	}
	
	/// User tapped on the button
	@objc func primaryButtonTapped() {
		
		if pageViewController.isLastPage {
			// We tapped on the last page
			viewModel.finish(.updatePageViewed)
		} else {
			// Move to the next page
			pageViewController.nextPage()
		}
	}
}

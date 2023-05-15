/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import ReusableViews
import Shared

class ExportLoopViewController: TraitWrappedGenericViewController<ExportLoopView, ExportLoopViewModel> {

	override func viewDidLoad() {
		
		super.viewDidLoad()
		setupBinding()
		addBackButton()
	}
	
	private func setupBinding() {
		
		viewModel.title.observe { [weak self] in self?.title = $0 }
		viewModel.image.observe { [weak self] in self?.sceneView.imageView.image = $0 }
		viewModel.qrAccessibilityTitle.observe { [weak self] (qrAccessibilityTitle: String) in
			self?.sceneView.imageView.isAccessibilityElement = true
			self?.sceneView.imageView.accessibilityLabel = qrAccessibilityTitle
		}
		viewModel.step.observe { [weak self] in self?.sceneView.step = $0 }
		viewModel.header.observe { [weak self] in self?.sceneView.header = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }
		viewModel.actionTitle.observe { [weak self] in self?.sceneView.primaryTitle = $0 }
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.done() }
		viewModel.pageControlCount.observe { [weak self] in
			self?.sceneView.pageControl.numberOfPages = $0
			guard $0 > 0 else { return }
			// Pin page control to the last dot.
			self?.sceneView.pageControl.update(for: $0 - 1)
		}
		sceneView.pageControl.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		viewModel.viewWillAppear()
		if UIDevice.current.userInterfaceIdiom == .phone {
			OrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
		}
		sceneView.layoutForOrientation(isLandScape: UIDevice.current.isLandscape)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		
		super.viewDidDisappear(animated)
		viewModel.viewWillDisappear()
		if UIDevice.current.userInterfaceIdiom == .phone {
			OrientationUtility.unlockOrientation()
		}
	}
	
	override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
		
		self.sceneView.layoutForOrientation(isLandScape: UIDevice.current.isLandscape)
		self.sceneView.setNeedsLayout()
	}
}

// PageControlDelegate

extension ExportLoopViewController: PageControlDelegate {
	func pageControl(didChangeToPageIndex currentPageIndex: Int, previousPageIndex: Int) {
		
		// the pageControl is fixed in the last page. So any click means go one page back.
		viewModel.backToPreviousScreen()
	}
}

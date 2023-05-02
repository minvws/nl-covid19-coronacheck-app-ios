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
		viewModel.step.observe { [weak self] in self?.sceneView.step = $0 }
		viewModel.header.observe { [weak self] in self?.sceneView.header = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }
		viewModel.actionTitle.observe { [weak self] in self?.sceneView.primaryTitle = $0 }
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.done() }
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		if UIDevice.current.userInterfaceIdiom == .phone {
			OrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
		}
		sceneView.layoutForOrientation(isLandScape: UIApplication.shared.isLandscape)
	}

	override func viewDidDisappear(_ animated: Bool) {

		super.viewDidDisappear(animated)
		if UIDevice.current.userInterfaceIdiom == .phone {
			OrientationUtility.unlockOrientation()
		}
	}
	
	override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
		
		self.sceneView.layoutForOrientation(isLandScape: UIApplication.shared.isLandscape)
		self.sceneView.setNeedsLayout()
	}
}

extension UIApplication {
	
	var isLandscape: Bool {
		if #available(iOS 13.0, *) {
			return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape ?? false
		} else {
			return UIApplication.shared.statusBarOrientation.isLandscape
		}
	}
}

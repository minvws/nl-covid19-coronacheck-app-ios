/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class AppStatusViewController: GenericViewController<AppStatusView, AppStatusViewModel> {

	override func viewDidLoad() {
		
		super.viewDidLoad()
		setupBinding()
	}

	private func setupBinding() {

		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }
		viewModel.image.observe { [weak self] in self?.sceneView.image = $0 }
		viewModel.actionTitle.observe { [weak self] in self?.sceneView.primaryTitle = $0 }
		viewModel.alert.observe { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.actionButtonTapped() }
		
		sceneView.urlTapHander = { [weak self] in
			self?.viewModel.userDidTapURL(url: $0)
		}
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		layoutForOrientation()
	}

	// Rotation

	override func willTransition(
		to newCollection: UITraitCollection,
		with coordinator: UIViewControllerTransitionCoordinator) {

		coordinator.animate { [weak self] _ in
			self?.layoutForOrientation()
		}
	}

	/// Layout for different orientations
	func layoutForOrientation() {

		if UIDevice.current.isSmallScreen || traitCollection.verticalSizeClass == .compact {
			// Also hide on small screens
			sceneView.hideImage()
		} else {
			sceneView.showImage()
		}
	}
}

/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppStatusViewController: GenericViewController<AppStatusView, AppStatusViewModel> {

	/// The error Message
	var errorMessage: String?

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		modalPresentationStyle = .overFullScreen
		
		// Do the binding
		setupBinding()
		
		// Actions
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	private func setupBinding() {

		// Binding
		viewModel.$showCannotOpenAlert.binding = { [weak self] in
			if $0 {
				self?.showCannotOpenUrl()
			}
		}
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$image.binding = { [weak self] in self?.sceneView.image = $0 }
		viewModel.$errorMessage.binding = { [weak self] in self?.errorMessage = $0 }
		viewModel.$actionTitle.binding = { [weak self] in self?.sceneView.primaryButton.setTitle($0, for: .normal) }
	}

	/// User tapped on the button
    @objc private func primaryButtonTapped() {

		viewModel.actionButtonTapped()
    }

	/// Show alert that we can't open the url
	private func showCannotOpenUrl() {
		
		showAlert(
			AlertContent(
				title: L.generalErrorTitle(),
				subTitle: errorMessage ?? "",
				okAction: AlertContent.Action.okay
			)
		)
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

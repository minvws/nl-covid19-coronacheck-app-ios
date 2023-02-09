/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class PolicyInformationViewController: TraitWrappedGenericViewController<PolicyInformationView, PolicyInformationViewModel> {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		viewModel.$image.binding = { [weak self] in self?.sceneView.image = $0 }
		viewModel.$tagline.binding = { [weak self] in self?.sceneView.tagline = $0 }
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$content.binding = { [weak self] in self?.sceneView.content = $0 }
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.footerButtonView.primaryTitle = $0 }
		
		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			
			self?.viewModel.finish()
		}
		
		addBackButton()
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
			self?.sceneView.setNeedsLayout()
		}
	}

	/// Layout for different orientations
	func layoutForOrientation() {

		if UIDevice.current.isSmallScreen || traitCollection.verticalSizeClass == .compact {
			// Also hide the image on small devices
			sceneView.hideImage()
		} else {
			sceneView.showImage()
		}
	}
}

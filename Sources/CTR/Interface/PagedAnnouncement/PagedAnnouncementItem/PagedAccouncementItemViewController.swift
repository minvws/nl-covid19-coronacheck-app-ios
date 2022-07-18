/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol PagedAnnouncementItemViewControllerDelegate: AnyObject {
	
	/// Delegates the onAccessibilityScroll event
	func onAccessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool
}

class PagedAnnouncementItemViewController: TraitWrappedGenericViewController<PagedAnnouncementItemView, PagedAnnouncementItemViewModel> {
	
	/// The delegate
	weak var delegate: PagedAnnouncementItemViewControllerDelegate?
	
	/// Disable swiping to launch screen
	override var enableSwipeBack: Bool { false }
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: PagedAnnouncementItemViewModel, shouldShowWithFullWidthHeaderImage: Bool) {
		
		super.init(
			sceneView: PagedAnnouncementItemView(shouldShowWithFullWidthHeaderImage: shouldShowWithFullWidthHeaderImage),
			viewModel: viewModel
		)
	}
	
	/// Use accessibility scroll event to navigate.
	override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
		return delegate?.onAccessibilityScroll(direction) ?? false
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$tagline.binding = { [weak self] in self?.sceneView.tagline = $0 }
		viewModel.$content.binding = { [weak self] in self?.sceneView.content = $0 }
		viewModel.$image.binding = { [weak self] in self?.sceneView.image = $0 }
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

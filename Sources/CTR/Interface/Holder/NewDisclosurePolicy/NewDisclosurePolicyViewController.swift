/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class NewDisclosurePolicyViewController: BaseViewController {
	
	/// The model
	private let viewModel: NewDisclosurePolicyViewModel
	
	/// The view
	let sceneView = NewDisclosurePolicyView()
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: NewDisclosurePolicyViewModel) {
		
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
		
		viewModel.$image.binding = { [weak self] in self?.sceneView.image = $0 }
		viewModel.$tagline.binding = { [weak self] in self?.sceneView.tagline = $0 }
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$content.binding = { [weak self] in self?.sceneView.content = $0 }
		
		addCloseButton(action: #selector(closeButtonTapped))
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
	
	/// User tapped on the button
	@objc func closeButtonTapped() {
		
		viewModel.dismiss()
	}
}

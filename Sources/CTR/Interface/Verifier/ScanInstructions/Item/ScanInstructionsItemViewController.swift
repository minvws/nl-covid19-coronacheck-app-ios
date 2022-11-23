/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ScanInstructionsItemViewControllerDelegate: AnyObject {
    
    /// Delegates the onAccessibilityScroll event
    func onAccessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool
}

class ScanInstructionsItemViewController: BaseViewController {
	
	/// The model
	private let viewModel: ScanInstructionsItemViewModel
	
	/// The view
	let sceneView = ScanInstructionsItemView()
    
    /// The delegate
    weak var delegate: ScanInstructionsItemViewControllerDelegate?
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ScanInstructionsItemViewModel) {
		
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
    
    /// Use accessibility scroll event to navigate.
    override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        return delegate?.onAccessibilityScroll(direction) ?? false
    }
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$animationName.binding = { [weak self] in self?.sceneView.animationName = $0 }
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		layoutForOrientation()
	}
	
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)
		sceneView.play()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		
		super.viewDidDisappear(animated)
		sceneView.reset()
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

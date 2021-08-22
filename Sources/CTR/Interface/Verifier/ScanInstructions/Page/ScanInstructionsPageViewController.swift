/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ScanInstructionsPageViewControllerDelegate: AnyObject {
    
    /// Delegates the onAccessibilityScroll event
    func onAccessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool
}

class ScanInstructionsPageViewController: BaseViewController {
	
	/// The model
	private let viewModel: ScanInstructionsPageViewModel
	
	/// The view
	let sceneView = ScanInstructionsPageView()
    
    /// The delegate
    weak var delegate: ScanInstructionsPageViewControllerDelegate?
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ScanInstructionsPageViewModel) {
		
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

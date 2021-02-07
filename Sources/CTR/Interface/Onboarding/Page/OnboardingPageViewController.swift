/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingPageViewController: BaseViewController {
	
	/// The model
	private let viewModel: OnboardingPageViewModel
	
	/// The view
	let sceneView = OnboardingPageView()
	
	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: OnboardingPageViewModel) {
		
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Show always in portrait
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
	
	// MARK: View lifecycle
	override func loadView() {
		
		view = sceneView
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		viewModel.$title.binding = { self.sceneView.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }
		viewModel.$image.binding = { self.sceneView.image = $0 }
	}
}

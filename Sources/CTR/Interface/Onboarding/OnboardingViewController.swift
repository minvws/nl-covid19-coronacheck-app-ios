/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingViewModel {

	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var step: Int

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: OnboardingCoordinatorDelegate, onboardingInfo: OnboardingInfo) {

		self.coordinator = coordinator

		title = onboardingInfo.title
		message = onboardingInfo.message
		image = onboardingInfo.image
		step = onboardingInfo.step.rawValue
	}
}

class OnboardingViewController: BaseViewController {

	/// The model
	let viewModel: OnboardingViewModel

	/// The view
	let sceneView = OnboardingView()

	/// The error Message
	var errorMessage: String?

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: OnboardingViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
//		modalPresentationStyle = .overFullScreen
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

		viewModel.$title.binding = {

			self.sceneView.titleLabel.text = $0
		}

		viewModel.$message.binding = {

			self.sceneView.messageLabel.text = $0
		}
		viewModel.$image.binding = {

			self.sceneView.imageView.image = $0
		}
		viewModel.$step.binding = {

			self.sceneView.pageControl.currentPage = $0
		}

		sceneView.primaryButton.setTitle(.next, for: .normal)
		sceneView.pageControl.numberOfPages = 5

		navigationItem.hidesBackButton = true

//		// Actions
//		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingViewController: BaseViewController {

	/// The model
	let viewModel: OnboardingViewModel

	/// The view
	let sceneView = OnboardingView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: OnboardingViewModel) {

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
		viewModel.$underlinedText.binding = {
			self.sceneView.underline($0)
			self.setupLink()
		}
		viewModel.$image.binding = { self.sceneView.image = $0 }
		viewModel.$numberOfPages.binding = { self.sceneView.pageControl.numberOfPages = $0 }
		viewModel.$pageNumber.binding = {

			self.sceneView.pageControl.currentPage = $0
			self.navigationItem.hidesBackButton = $0 == 0
		}

		sceneView.primaryButton.setTitle(.next, for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		sceneView.messageLabel.addGestureRecognizer(tapGesture)
		sceneView.messageLabel.isUserInteractionEnabled = true
	}

	/// User tapped on the button
	@objc func primaryButtonTapped() {

		viewModel.nextButtonClicked()
	}

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkClicked(self)
	}
}

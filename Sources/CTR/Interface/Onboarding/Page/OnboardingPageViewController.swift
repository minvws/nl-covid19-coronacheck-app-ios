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
		viewModel.$underlinedText.binding = {
			self.sceneView.underline($0)
			self.setupLink()
		}
		viewModel.$image.binding = { self.sceneView.image = $0 }

		viewModel.$consent.binding = {
			self.sceneView.consent = $0
		}
		self.sceneView.consentButton.valueChanged(self, action: #selector(consentValueChanged))
	}

	/// Setup a gesture recognizer for underlined text
	private func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		sceneView.messageLabel.addGestureRecognizer(tapGesture)
		sceneView.messageLabel.isUserInteractionEnabled = true
	}

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkClicked(self)
	}

	/// User tapped on the consent button
	@objc func consentValueChanged(_ sender: ConsentButton) {

		viewModel.consentGiven(sender.isSelected)
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		if self.sceneView.consent != nil {
			// if there is a consent button, notify the model (and thus the container) of its state
			viewModel.consentGiven(sceneView.consentButton.isSelected)
		}
	}
}

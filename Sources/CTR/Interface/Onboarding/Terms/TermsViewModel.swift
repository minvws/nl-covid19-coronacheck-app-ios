//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

class TermsViewModel {

	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var agree: String

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - onboardingInfo: the container with onboarding info
	///   - numberOfPages: the total number of pages
	init(
		coordinator: OnboardingCoordinatorDelegate) {

		self.coordinator = coordinator
		self.title = .termsTitle
		self.message = .termsMessage
		self.agree = .termsAgree
	}

	/// The user tapped on the next button
	func nextButtonClicked() {

		coordinator?.termsAgreed()
	}
}

class TermsViewController: BaseViewController {

	/// The model
	let viewModel: TermsViewModel

	/// The view
	let sceneView = TermsView()

	/// The error Message
	var errorMessage: String?

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: TermsViewModel) {

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
		viewModel.$agree.binding = { self.sceneView.agree = $0 }

		sceneView.primaryButton.setTitle(.next, for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		sceneView.primaryButton.isEnabled = false

		sceneView.toggleView.addTarget(self, action: #selector(valueChange), for: .valueChanged)
	}

	@objc func valueChange(mySwitch: UISwitch) {

		sceneView.primaryButton.isEnabled = mySwitch.isOn
	}

	/// User tapped on the button
	@objc func primaryButtonTapped() {

		viewModel.nextButtonClicked()
	}
}

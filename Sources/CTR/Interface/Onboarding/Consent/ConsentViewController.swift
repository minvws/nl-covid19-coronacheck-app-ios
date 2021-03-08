/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ConsentViewController: BaseViewController {

	/// The model
	let viewModel: ConsentViewModel

	/// The view
	let sceneView = ConsentView()

	/// The page controller
	private var pageViewController: UIPageViewController?

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ConsentViewModel) {

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

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$underlinedText.binding = { [weak self] in
			self?.sceneView.underline($0)
			self?.setupLink()
		}

		viewModel.$isContinueButtonEnabled.binding = { [weak self] in self?.sceneView.primaryButton.isEnabled = $0 }
		sceneView.primaryButton.setTitle(.next, for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))

		viewModel.$consentText.binding = { [weak self] in self?.sceneView.consent = $0 }
		self.sceneView.consentButton.valueChanged(self, action: #selector(consentValueChanged))

		viewModel.$summary.binding = { [weak self] in

			for item in $0 {
				self?.sceneView.addPrivacyItem(item)
			}
		}
	}

	/// Setup a gesture recognizer for underlined text
	private func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		sceneView.messageLabel.addGestureRecognizer(tapGesture)
		sceneView.messageLabel.isUserInteractionEnabled = true
	}

	/// User tapped on the consent button
	@objc func consentValueChanged(_ sender: ConsentButton) {

		viewModel.consentGiven(sender.isSelected)
	}

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkTapped(self)
	}

	/// The user tapped on the primary button
	@objc func primaryButtonTapped() {

		if sceneView.primaryButton.isEnabled {
			viewModel.primaryButtonTapped()
		}
	}
}

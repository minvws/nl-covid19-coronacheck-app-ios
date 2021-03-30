/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierStartViewController: BaseViewController {

	private let viewModel: VerifierStartViewModel

	let sceneView = HeaderTitleMessageButtonView()

	init(viewModel: VerifierStartViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {

        super.viewDidLoad()

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$header.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }

		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.primaryButtonTapped()
		}

		viewModel.$linkedMessage.binding = { [weak self] in

			self?.sceneView.underline($0)
			self?.setupLink()
		}

		viewModel.$showError.binding = { [weak self] in
			if $0 {
				self?.showError(.errorTitle, message: .verifierStartInternet)
			}
		}

		sceneView.headerImage = .scanStart
		// Only show an arrow as back button
		styleBackButton(buttonText: "")
    }

	// MARK: Helper methods

	/// Setup a gesture recognizer for underlined text
	private func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		sceneView.messageLabel.addGestureRecognizer(tapGesture)
		sceneView.messageLabel.isUserInteractionEnabled = true
	}

	// MARK: User interaction

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkTapped(self)
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		checkImage()
	}

	// Rotation

	override func willTransition(
		to newCollection: UITraitCollection,
		with coordinator: UIViewControllerTransitionCoordinator) {

		coordinator.animate { [weak self] _ in
			self?.checkImage()
			self?.sceneView.setNeedsLayout()
		}
	}

	func checkImage() {

		if UIDevice.current.isLandscape {
			sceneView.hideImage()
		} else {
			sceneView.showImage()
		}
	}
}

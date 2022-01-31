/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierStartViewController: BaseViewController {

	private let viewModel: VerifierStartViewModel

	let sceneView = VerifierStartView()
	
	override var enableSwipeBack: Bool { false }
	
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

		setupBindings()
    }

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		navigationController?.navigationBar.isHidden = true
		
		layoutForOrientation()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		navigationController?.navigationBar.isHidden = false

		// As the screen animates out, fade out the (fake) navigation bar,
		// as an approximation of the animation that occurs with UINavigationBar.
		transitionCoordinator?.animate(alongsideTransition: { _ in
			self.sceneView.fakeNavigationBarAlpha = 0
		}, completion: { _ in
			self.sceneView.fakeNavigationBarAlpha = 1
		})
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

		if traitCollection.verticalSizeClass == .compact {
			sceneView.hideImage()
		} else {
			sceneView.showImage()
		}
	}
	
	// MARK: - Setup
	
	private func setupBindings() {
		viewModel.$title.binding = { [weak self] in self?.sceneView.fakeNavigationTitle = $0 }
		viewModel.$header.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$showInstructionsTitle.binding = { [weak self] in self?.sceneView.showInstructionsTitle = $0 }
		viewModel.$showsInstructionsButton.binding = { [weak self] in self?.sceneView.showsInstructionsButton = $0 }
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		viewModel.$showsPrimaryButton.binding = { [weak self] in self?.sceneView.showsPrimaryButton = $0 }
		viewModel.$shouldShowClockDeviationWarning.binding = { [weak self] in
			self?.sceneView.clockDeviationWarningView.isHidden = !$0
			self?.sceneView.clockDeviationWarningView.buttonCommand = {
				self?.viewModel.userDidTapClockDeviationWarningReadMore()
			}
		}
		viewModel.$largeImage.binding = { [weak self] in self?.sceneView.largeImage = $0 }
		viewModel.$showError.binding = { [weak self] in
			if $0 {
				self?.showError(L.generalErrorTitle(), message: L.verifierStartOntimeinternet())
			}
		}
		viewModel.$riskIndicator.binding = { [weak self] in
			self?.sceneView.setRiskIndicator(params: $0)
		}

		sceneView.clockDeviationWarningView.message = L.verifierStartClockdeviationwarningMessage()
		sceneView.clockDeviationWarningView.buttonTitle = L.verifierStartClockdeviationwarningButton()

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.primaryButtonTapped()
		}

		sceneView.showInstructionsButtonTappedCommand = { [weak self] in
			self?.viewModel.showInstructionsButtonTapped()
		}
		
		sceneView.tapMenuButtonHandler = { [weak self] in
			self?.viewModel.userTappedMenuButton()
		}
	}
}

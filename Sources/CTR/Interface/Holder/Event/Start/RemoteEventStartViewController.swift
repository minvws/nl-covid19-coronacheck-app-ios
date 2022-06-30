/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class RemoteEventStartViewController: BaseViewController {

	internal let viewModel: RemoteEventStartViewModel
	internal let sceneView = RemoteEventStartView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: RemoteEventStartViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initializer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = TraitWrapper(sceneView)
	}

	override func viewDidLoad() {

		super.viewDidLoad()
		
		navigationController?.delegate = self

		setupBinding()
		setupInteraction()
	}

	private func setupBinding() {

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$primaryButtonIcon.binding = { [weak self] in self?.sceneView.primaryButtonIcon = $0 }
		viewModel.$checkboxTitle.binding = { [weak self] in self?.sceneView.checkboxTitle = $0 }
		viewModel.$combineVaccinationAndPositiveTest.binding = { [weak self] in self?.sceneView.info = $0 }
	}

	private func setupInteraction() {

		sceneView.primaryTitle = L.holderVaccinationStartAction()
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.primaryButtonTapped() }

		sceneView.secondaryButtonTitle = L.holderVaccinationStartNodigid()
		sceneView.secondaryButtonTappedCommand = { [weak self] in

			if let url = URL(string: L.holderVaccinationStartNodigidUrl()) {
				self?.viewModel.openUrl(url)
			}
		}

		sceneView.contentTextView.linkTouchedHandler = { [weak self] url in self?.viewModel.openUrl(url) }

		sceneView.didToggleCheckboxCommand = { [weak self] value in self?.viewModel.checkboxToggled(value: value) }
		
		addBackButton(customAction: #selector(backButtonTapped))
	}

	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
	}
}

extension RemoteEventStartViewController: UINavigationControllerDelegate {
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

		if let coordinator = navigationController.topViewController?.transitionCoordinator {
			coordinator.notifyWhenInteractionChanges { [weak self] context in
				guard !context.isCancelled else { return }
				// Clean up coordinator when swiping back
				self?.viewModel.backSwipe()
			}
		}
	}
}

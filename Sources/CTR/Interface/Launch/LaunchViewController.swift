/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LaunchViewController: BaseViewController {

	/// The model
	private let viewModel: LaunchViewModel

	/// The view
	let sceneView = LaunchView()

	// MARK: Initializers

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: LaunchViewModel) {

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

	override func viewDidLoad() {

		super.viewDidLoad()

		// Bindings
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$version.binding = { [weak self] in self?.sceneView.version = $0 }
		viewModel.$appIcon.binding = { [weak self] in self?.sceneView.appIcon = $0 }
		viewModel.$shouldShowJailBreakDialog.binding = { [weak self] in
			if $0 {
				self?.showJailBreakWarning()
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		sceneView.spinner.startAnimating()
		layoutForOrientation()
	}

	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)
		checkRequirements()
	}

	func checkRequirements() {

		viewModel.checkRequirements()
	}

	private func showJailBreakWarning() {

		let alertController = UIAlertController(
			title: .jailbrokenTitle,
			message: .jailbrokenTitle,
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: .ok,
				style: .default,
				handler: { [weak self] _ in
					self?.viewModel.jailBreakWarningDismissed()
				}
			)
		)
		present(alertController, animated: true, completion: nil)
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
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppointmentViewController: BaseViewController {

	private let viewModel: AppointmentViewModel

	let sceneView = HeaderTitleMessageButtonView()

	// MARK: Initializers

	init(viewModel: AppointmentViewModel) {

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
		viewModel.$body.binding = { [weak self] in self?.sceneView.message = $0 }

		viewModel.$buttonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		viewModel.$image.binding = { [weak self] in
			self?.sceneView.headerImage = $0
			self?.sceneView.headerImageView.backgroundColor = Theme.colors.appointment
			self?.sceneView.stackView.backgroundColor = Theme.colors.appointment
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.buttonTapped()
		}

		sceneView.contentTextView.linkTouched { [weak self] url in

			self?.viewModel.openUrl(url)
		}
	}

	// MARK: Helper methods

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		layoutForOrientation()
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

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutMakingAQRViewController: BaseViewController {

	private let viewModel: AboutMakingAQRViewModel

	let sceneView = AboutMakingAQRView()

	// MARK: Initializers

	init(viewModel: AboutMakingAQRViewModel) {

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
		viewModel.$header.binding = { [weak self] in self?.sceneView.header = $0 }
		viewModel.$body.binding = { [weak self] in self?.sceneView.body = $0 }
		viewModel.$image.binding = { [weak self] in self?.sceneView.headerImage = $0 }

		sceneView.buttonTitle = L.generalNext()

		sceneView.contentTextView.linkTouched { [weak self] url in
			self?.viewModel.userTouchedURL(url)
		}

		sceneView.button.touchUpInside(viewModel, action: #selector(AboutMakingAQRViewModel.userTappedNext))

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

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
	private func layoutForOrientation() {

		if traitCollection.verticalSizeClass == .compact {
			sceneView.hideImage()
		} else {
			sceneView.showImage()
		}
	}
}

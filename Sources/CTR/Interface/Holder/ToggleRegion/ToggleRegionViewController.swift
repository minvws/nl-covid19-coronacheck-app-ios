/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ToggleRegionViewController: UIViewController {

	private let viewModel: ToggleRegionViewModel

	let sceneView = ToggleRegionView()

	init(viewModel: ToggleRegionViewModel) {
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupBindings()

		sceneView.toggleRegionSelectedIndexChangedCommand = { [weak viewModel] in
			viewModel?.didSelectIndex($0)
		}
	}

	private func setupBindings() {
		viewModel.$topText.binding = { [weak sceneView] in
			sceneView?.topText = $0
		}

		viewModel.$bottomText.binding = { [weak sceneView] in
			sceneView?.bottomText = $0
		}

		viewModel.$segments.binding = { [weak sceneView] in
			sceneView?.segmentValues = $0
		}
	}
}

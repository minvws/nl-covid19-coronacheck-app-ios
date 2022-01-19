/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ContentViewController: BaseViewController {

	/// The model
	private let viewModel: ContentViewModel

	/// The view
	let sceneView = ContentView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ContentViewModel) {

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

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$body.binding = { [weak self] in self?.sceneView.body = $0 }
		viewModel.$secondaryButtonTitle.binding = { [weak self] in
			self?.sceneView.secondaryButtonTitle = $0
		}
		viewModel.$hideForCapture.binding = { [weak self] in
			self?.sceneView.handleScreenCapture(shouldHide: $0)
		}

		sceneView.messageLinkTapHandler = { [weak viewModel] url in
			viewModel?.userDidTapURL(url: url)
		}
		sceneView.secondaryButtonTappedCommand = { [weak viewModel] in
			viewModel?.userDidTapSecondaryButton()
		}
	}
}

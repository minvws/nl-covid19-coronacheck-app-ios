/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class InformationViewController: BaseViewController {

	/// The model
	private let viewModel: InformationViewModel

	/// The view
	let sceneView = InformationView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: InformationViewModel) {

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
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }

		sceneView.linkTapHandler = { [viewModel] url in
			viewModel.userDidTapURL(url: url)
		}

		viewModel.$hideForCapture.binding = { [weak self] in

			self?.sceneView.handleScreenCapture(shouldHide: $0)
		}
	}
}

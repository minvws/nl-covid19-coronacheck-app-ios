/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class SnapshotViewController: BaseViewController {

	/// The model
	private let viewModel: SnapshotViewModel

	/// The view
	let sceneView = LaunchView()

	// MARK: Initializers

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: SnapshotViewModel) {

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
		viewModel.$version.binding = { [weak self] in self?.sceneView.version = $0 }
		viewModel.$appIcon.binding = { [weak self] in self?.sceneView.appIcon = $0 }
		viewModel.$dismiss.binding = { [weak self] in
			if $0 {
				self?.dismiss(animated: true, completion: nil)
			}
		}
	}
}

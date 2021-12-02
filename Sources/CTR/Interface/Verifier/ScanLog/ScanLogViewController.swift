/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanLogViewController: BaseViewController {

	private let viewModel: ScanLogViewModel

	let sceneView = ScanLogView()

	override var enableSwipeBack: Bool { false }

	init(viewModel: ScanLogViewModel) {

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
		addBackButton()
		setupBindings()
	}

	private func setupBindings() {

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$appInUseSince.binding = { [weak self] in self?.sceneView.footer = $0 }

		sceneView.messageTextView.linkTouched { [weak self] url in

			self?.viewModel.openUrl(url)
		}

	}
}

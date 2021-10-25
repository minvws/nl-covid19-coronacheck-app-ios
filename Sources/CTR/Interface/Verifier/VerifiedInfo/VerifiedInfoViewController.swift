/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class VerifiedInfoViewController: BaseViewController {
	
	/// The model
	private let viewModel: VerifiedInfoViewModel

	/// The view
	let sceneView = VerifiedInfoView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: VerifiedInfoViewModel) {

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
		viewModel.$primaryTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		viewModel.$primaryButtonIcon.binding = { [weak self] in self?.sceneView.primaryButtonIcon = $0 }
		
		sceneView.primaryButton.touchUpInside(viewModel, action: #selector(VerifiedInfoViewModel.onTap))
		
		addBackButton()
	}
}

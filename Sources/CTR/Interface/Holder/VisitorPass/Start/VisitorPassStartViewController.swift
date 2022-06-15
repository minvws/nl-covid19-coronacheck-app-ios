/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class VisitorPassStartViewController: BaseViewController {
	
	/// The model
	private let viewModel: VisitorPassStartViewModel

	/// The view
	let sceneView = VisitorPassStartView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: VisitorPassStartViewModel) {

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

		view = TraitWrapper(sceneView)
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		addBackButton(customAction: nil)
		
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$buttonTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.navigateToTokenEntry() }
		sceneView.contentTextView.linkTouchedHandler = { [weak self] url in self?.viewModel.openUrl(url) }
	}
}

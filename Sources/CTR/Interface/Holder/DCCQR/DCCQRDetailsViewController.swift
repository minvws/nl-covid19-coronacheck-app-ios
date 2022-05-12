/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DCCQRDetailsViewController: BaseViewController {

	/// The model
	internal let viewModel: DCCQRDetailsViewModel

	/// The view
	let sceneView = DCCQRDetailsView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: DCCQRDetailsViewModel) {

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
		
		viewModel.$description.binding = { [weak self] in self?.sceneView.detailsDescription = $0 }
		
		viewModel.$details.binding = { [weak self] in self?.sceneView.details = $0 }
		
		viewModel.$dateInformation.binding = { [weak self] in self?.sceneView.dateInformation = $0 }

		viewModel.$hideForCapture.binding = { [weak self] in self?.sceneView.handleScreenCapture(shouldHide: $0) }
		
		sceneView.dosageLinkTouchedCommand = { [weak self] url in
			
			self?.viewModel.openUrl(url)
		}
	}
}

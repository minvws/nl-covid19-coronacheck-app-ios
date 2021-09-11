/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PaperCertificateAboutScanViewController: BaseViewController {
	
	private let viewModel: PaperCertificateAboutScanViewModel
	
	let sceneView = PaperCertificateAboutScanView()
	
	init(viewModel: PaperCertificateAboutScanViewModel) {
		
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
		
		setupBinding()
		
		styleBackButton()
	}
	
	func setupBinding() {
		
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }

		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.primaryButton.title = $0 }
		
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.primaryButtonTapped() }
	}
}

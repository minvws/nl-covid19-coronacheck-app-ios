/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

final class ScanNextInstructionViewController: BaseViewController {
	
	private let viewModel: ScanNextInstructionViewModel
	
	let sceneView = ScanNextInstructionView()
	
	init(viewModel: ScanNextInstructionViewModel) {
		
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
		
		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			
			self?.viewModel.scanNextQR()
		}
		sceneView.noProofAvailableCommand = { [weak self] in
			
			self?.viewModel.denyAccess()
		}
		
		viewModel.$subtitle.binding = { [weak self] in self?.sceneView.subtitle = $0 }
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$header.binding = { [weak self] in self?.sceneView.header = $0 }
		viewModel.$primaryTitle.binding = { [weak self] in self?.sceneView.primaryTitle = $0 }
		viewModel.$secondaryTitle.binding = { [weak self] in self?.sceneView.secondaryTitle = $0 }
		
		addBackButton()
	}
}

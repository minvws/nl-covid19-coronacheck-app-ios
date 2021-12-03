/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingStartViewController: BaseViewController {
	
	private let viewModel: RiskSettingStartViewModel

	let sceneView = RiskSettingStartView()
	
	init(viewModel: RiskSettingStartViewModel) {

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
		
		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$header.binding = { [weak self] in self?.sceneView.header = $0 }
		viewModel.$primaryTitle.binding = { [weak self] in self?.sceneView.footerButtonView.primaryTitle = $0 }
		viewModel.$readMoreButtonTitle.binding = { [weak self] in self?.sceneView.readMoreButtonTitle = $0 }
		
		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			
			self?.viewModel.showRiskSetting()
		}
	}
}

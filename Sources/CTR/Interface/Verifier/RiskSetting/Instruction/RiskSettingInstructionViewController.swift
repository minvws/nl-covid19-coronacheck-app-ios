/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingInstructionViewController: BaseViewController {
	
	private let viewModel: RiskSettingInstructionViewModel

	let sceneView = RiskSettingInstructionView()

	init(viewModel: RiskSettingInstructionViewModel) {

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
		viewModel.$lowRiskTitle.binding = { [weak self] in self?.sceneView.lowRiskTitle = $0 }
		viewModel.$lowRiskSubtitle.binding = { [weak self] in self?.sceneView.lowRiskSubtitle = $0 }
		viewModel.$highRiskTitle.binding = { [weak self] in self?.sceneView.highRiskTitle = $0 }
		viewModel.$highRiskSubtitle.binding = { [weak self] in self?.sceneView.highRiskSubtitle = $0 }
		viewModel.$moreButtonTitle.binding = { [weak self] in self?.sceneView.moreButtonTitle = $0 }
		viewModel.$riskSetting.binding = { [weak self] in self?.sceneView.riskSetting = $0 }
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.footerButtonView.primaryButton.title = $0 }
		
		sceneView.selectRiskCommand = { [weak self] riskSetting in
			
			self?.viewModel.selectRisk = riskSetting
		}
		sceneView.readMoreCommand = { [weak self] in
			
			self?.viewModel.showReadMore()
		}
		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			
			self?.viewModel.startScanner()
		}
		
		addBackButton()
	}
}

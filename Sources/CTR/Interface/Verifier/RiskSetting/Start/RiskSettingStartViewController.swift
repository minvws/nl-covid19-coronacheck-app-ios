/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingStartViewController: GenericViewController<RiskSettingStartView, RiskSettingStartViewModel> {
	
	override var enableSwipeBack: Bool { true }
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		addBackButton(customAction: nil)
		
		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$header.binding = { [weak self] in self?.sceneView.header = $0 }
		viewModel.$primaryTitle.binding = { [weak self] in self?.sceneView.footerButtonView.primaryTitle = $0 }
		viewModel.$readMoreButtonTitle.binding = { [weak self] in self?.sceneView.readMoreButtonTitle = $0 }
		viewModel.$changeRiskTitle.binding = { [weak self] in self?.sceneView.changeRiskSettingView.title = $0 }
		viewModel.$changeRiskSubtitle.binding = { [weak self] in self?.sceneView.changeRiskSettingView.subtitle = $0 }
		viewModel.$changeRiskButton.binding = { [weak self] in self?.sceneView.changeRiskSettingView.changeButtonTitle = $0 }
		viewModel.$hasUnselectedRiskLevel.binding = { [weak self] in self?.sceneView.hasUnselectedRiskState = $0 }
		
		sceneView.readMoreCommand = { [weak self] in
			
			self?.viewModel.showReadMore()
		}
		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			
			self?.viewModel.showRiskSetting()
		}
		sceneView.changeRiskSettingView.changeButtonCommand = { [weak self] in
			
			self?.viewModel.showRiskSetting()
		}
	}
}

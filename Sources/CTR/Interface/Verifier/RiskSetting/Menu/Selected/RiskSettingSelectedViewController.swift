/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class RiskSettingSelectedViewController: GenericViewController<RiskSettingSelectedView, RiskSettingSelectedViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()
		
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$header.binding = { [weak self] in self?.sceneView.header = $0 }
		viewModel.$lowRiskTitle.binding = { [weak self] in self?.sceneView.riskSettingControlsView.lowRiskTitle = $0 }
		viewModel.$lowRiskSubtitle.binding = { [weak self] in self?.sceneView.riskSettingControlsView.lowRiskSubtitle = $0 }
		viewModel.$lowRiskAccessibilityLabel.binding = { [weak self] in self?.sceneView.riskSettingControlsView.lowRiskAccessibilityLabel = $0 }
		viewModel.$highRiskTitle.binding = { [weak self] in self?.sceneView.riskSettingControlsView.highRiskTitle = $0 }
		viewModel.$highRiskSubtitle.binding = { [weak self] in self?.sceneView.riskSettingControlsView.highRiskSubtitle = $0 }
		viewModel.$highRiskAccessibilityLabel.binding = { [weak self] in self?.sceneView.riskSettingControlsView.highRiskAccessibilityLabel = $0 }
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.footerButtonView.primaryTitle = $0 }
		viewModel.$verificationPolicy.binding = { [weak self] in self?.sceneView.riskSettingControlsView.verificationPolicy = $0 }
		viewModel.$alert.binding = { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}
		sceneView.riskSettingControlsView.selectVerificationPolicyCommand = { [weak self] verificationPolicy in
			
			self?.viewModel.selectVerificationPolicy = verificationPolicy
		}
		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			
			self?.viewModel.confirmSetting()
		}
		
		addBackButton()
	}
}

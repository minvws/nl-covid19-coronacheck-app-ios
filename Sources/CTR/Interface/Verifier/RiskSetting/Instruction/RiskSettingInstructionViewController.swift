/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

final class RiskSettingInstructionViewController: GenericViewController<RiskSettingInstructionView, RiskSettingInstructionViewModel> {

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
		viewModel.$moreButtonTitle.binding = { [weak self] in self?.sceneView.moreButtonTitle = $0 }
		viewModel.$verificationPolicy.binding = { [weak self] in self?.sceneView.riskSettingControlsView.verificationPolicy = $0 }
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.footerButtonView.primaryTitle = $0 }
		viewModel.$errorMessage.binding = { [weak self] in self?.sceneView.errorMessage = $0 }
		viewModel.$shouldDisplayNotSetError.binding = { [weak self] in
			self?.sceneView.hasErrorState = $0
			if $0 {
				self?.sceneView.scrollView.scrollToBottomIfNotCompletelyVisible()
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					UIAccessibility.post(notification: .announcement, argument: self?.viewModel.errorMessage)
				}
			}
		}
		
		sceneView.riskSettingControlsView.selectVerificationPolicyCommand = { [weak self] verificationPolicy in
			
			self?.viewModel.selectVerificationPolicy = verificationPolicy
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

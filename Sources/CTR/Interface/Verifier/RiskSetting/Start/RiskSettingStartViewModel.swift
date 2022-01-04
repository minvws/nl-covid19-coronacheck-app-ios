/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class RiskSettingStartViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)?
	
	private let riskLevelManager: RiskLevelManaging
	
	/// The title of the scene
	@Bindable private(set) var title: String = L.verifier_risksetting_start_title()
	@Bindable private(set) var header: String = L.verifier_risksetting_start_header()
	@Bindable private(set) var primaryTitle: String = L.verifier_risksetting_setting_button()
	@Bindable private(set) var readMoreButtonTitle: String = L.verifier_risksetting_start_readmore()
	@Bindable private(set) var changeRiskTitle: String = L.verifier_risksetting_changeselection_3g()
	@Bindable private(set) var changeRiskSubtitle: String = L.verifier_risksetting_lowrisk_subtitle()
	@Bindable private(set) var changeRiskButton: String = L.verifier_risksetting_changeselection_button()
	@Bindable private(set) var hasUnselectedRiskLevel: Bool
	
	init(
		coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol),
		riskLevelManager: RiskLevelManaging = Services.riskLevelManager
	) {
		
		self.coordinator = coordinator
		self.riskLevelManager = riskLevelManager
		
		hasUnselectedRiskLevel = riskLevelManager.state == nil
		if let riskSetting = riskLevelManager.state {
			switch riskSetting {
				case .low:
					changeRiskTitle = L.verifier_risksetting_changeselection_3g()
					changeRiskSubtitle = L.verifier_risksetting_lowrisk_subtitle()
				case .high:
					changeRiskTitle = L.verifier_risksetting_changeselection_2g()
					changeRiskSubtitle = L.verifier_risksetting_highrisk_subtitle()
				case .highPlus:
					changeRiskTitle = L.verifier_risksetting_changeselection_2g_plus()
					changeRiskSubtitle = L.verifier_risksetting_2g_plus_subtitle()
			}
		}
	}
	
	func showReadMore() {
		guard let url = URL(string: L.verifier_risksetting_readmore_url()) else { return }
		
		coordinator?.openUrl(url, inApp: true)
	}
	
	func showRiskSetting() {
		
		coordinator?.userWishesToSetRiskLevel(shouldSelectSetting: hasUnselectedRiskLevel)
	}
}

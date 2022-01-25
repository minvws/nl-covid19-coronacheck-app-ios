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
	@Bindable private(set) var changeRiskTitle: String?
	@Bindable private(set) var changeRiskSubtitle: String = L.verifier_risksetting_lowrisk_subtitle()
	@Bindable private(set) var changeRiskButton: String = L.verifier_risksetting_changeselection_button()
	@Bindable private(set) var hasUnselectedRiskLevel: Bool
	
	init(
		coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol),
		riskLevelManager: RiskLevelManaging = Current.riskLevelManager
	) {
		
		self.coordinator = coordinator
		self.riskLevelManager = riskLevelManager
		
		hasUnselectedRiskLevel = riskLevelManager.state == nil
		if let verificationPolicy = riskLevelManager.state {
			changeRiskTitle = L.verifier_risksetting_changeselection(verificationPolicy.localization)
			
			switch verificationPolicy {
				case .policy3G:
					changeRiskSubtitle = L.verifier_risksetting_lowrisk_subtitle()
				case .policy1G:
					changeRiskSubtitle = L.verifier_risksetting_2g_plus_subtitle()
			}
			// TODO: Update copy
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

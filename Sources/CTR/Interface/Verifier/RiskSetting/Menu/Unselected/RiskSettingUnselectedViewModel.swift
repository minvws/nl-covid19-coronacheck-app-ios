/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class RiskSettingUnselectedViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)?
	
	private let riskLevelManager: RiskLevelManaging
	
	/// The title of the scene
	@Bindable private(set) var title = L.verifier_risksetting_firsttimeuse_title()
	@Bindable private(set) var lowRiskTitle = L.verifier_risksetting_lowrisk_title()
	@Bindable private(set) var lowRiskSubtitle = L.verifier_risksetting_lowrisk_subtitle()
	@Bindable private(set) var lowRiskAccessibilityLabel = "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
	@Bindable private(set) var highRiskTitle = L.verifier_risksetting_highrisk_title()
	@Bindable private(set) var highRiskSubtitle = L.verifier_risksetting_highrisk_subtitle()
	@Bindable private(set) var highRiskAccessibilityLabel = "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
	@Bindable private(set) var primaryButtonTitle = L.verifier_risksetting_confirmation_button()
	@Bindable private(set) var errorMessage = L.verification_policy_selection_error_message()
	@Bindable private(set) var shouldDisplayNotSetError = false
	
	var selectRisk: RiskLevel? {
		didSet {
			shouldDisplayNotSetError = false
		}
	}
	
	init(
		coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol),
		riskLevelManager: RiskLevelManaging = Current.riskLevelManager
	) {
		
		self.coordinator = coordinator
		self.riskLevelManager = riskLevelManager
	}
	
	func confirmSetting() {
		
		if selectRisk == nil {
			shouldDisplayNotSetError = true
		} else {
			riskLevelManager.update(riskLevel: selectRisk)
			coordinator?.navigateToVerifierWelcome()
		}
	}
}

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
	@Bindable private(set) var lowRiskTitle: String?
	@Bindable private(set) var lowRiskSubtitle = L.verifier_risksetting_lowrisk_subtitle()
	@Bindable private(set) var lowRiskAccessibilityLabel: String?
	@Bindable private(set) var highRiskTitle: String?
	@Bindable private(set) var highRiskSubtitle = L.verifier_risksetting_highrisk_subtitle()
	@Bindable private(set) var highRiskAccessibilityLabel: String?
	@Bindable private(set) var primaryButtonTitle = L.verifier_risksetting_confirmation_button()
	@Bindable private(set) var errorMessage = L.verification_policy_selection_error_message()
	@Bindable private(set) var shouldDisplayNotSetError = false
	
	var selectVerificationPolicy: VerificationPolicy? {
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
		
		let title3G = L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)
		lowRiskTitle = title3G
		lowRiskAccessibilityLabel = "\(title3G), \(L.verifier_risksetting_lowrisk_subtitle())"
		let title1G = L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)
		highRiskTitle = title1G
		highRiskAccessibilityLabel = "\(title1G), \(L.verifier_risksetting_highrisk_subtitle())"
	}
	
	func confirmSetting() {
		
		if selectVerificationPolicy == nil {
			shouldDisplayNotSetError = true
		} else {
			riskLevelManager.update(verificationPolicy: selectVerificationPolicy)
			coordinator?.navigateToVerifierWelcome()
		}
	}
}

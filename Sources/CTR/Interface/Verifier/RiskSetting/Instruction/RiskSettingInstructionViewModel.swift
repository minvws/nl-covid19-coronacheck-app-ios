/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class RiskSettingInstructionViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (ScanInstructionsCoordinatorDelegate & OpenUrlProtocol)?
	
	/// The title of the scene
	@Bindable private(set) var title = L.verifier_risksetting_firsttimeuse_title()
	@Bindable private(set) var header = L.verifier_risksetting_firsttimeuse_header()
	@Bindable private(set) var lowRiskTitle = L.verifier_risksetting_lowrisk_title()
	@Bindable private(set) var lowRiskSubtitle = L.verifier_risksetting_lowrisk_subtitle()
	@Bindable private(set) var lowRiskAccessibilityLabel = "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
	@Bindable private(set) var highRiskTitle = L.verifier_risksetting_highrisk_title()
	@Bindable private(set) var highRiskSubtitle = L.verifier_risksetting_highrisk_subtitle()
	@Bindable private(set) var highRiskAccessibilityLabel = "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
	@Bindable private(set) var highPlusRiskTitle = L.verifier_risksetting_2g_plus_title()
	@Bindable private(set) var highPlusRiskSubtitle = L.verifier_risksetting_2g_plus_subtitle()
	@Bindable private(set) var highPlusRiskAccessibilityLabel = "\(L.verifier_risksetting_2g_plus_title()), \(L.verifier_risksetting_2g_plus_subtitle())"
	@Bindable private(set) var moreButtonTitle = L.verifier_risksetting_readmore()
	@Bindable private(set) var primaryButtonTitle = L.verifierScaninstructionsButtonStartscanning()
	@Bindable private(set) var errorMessage = L.verification_policy_selection_error_message()
	@Bindable private(set) var shouldDisplayNotSetError = false
	@Bindable private(set) var riskLevel: RiskLevel?
	
	var selectRisk: RiskLevel? {
		didSet {
			shouldDisplayNotSetError = false
		}
	}
	
	init(coordinator: (ScanInstructionsCoordinatorDelegate & OpenUrlProtocol)) {
		
		self.coordinator = coordinator
		
		let selectedRisk = Current.riskLevelManager.state
		riskLevel = selectedRisk
		selectRisk = selectedRisk
	}
	
	func showReadMore() {
		guard let url = URL(string: L.verifier_risksetting_readmore_url()) else { return }
		
		coordinator?.openUrl(url, inApp: true)
	}
	
	func startScanner() {
		
		if selectRisk == nil {
			shouldDisplayNotSetError = true
		} else {
			Current.riskLevelManager.update(riskLevel: selectRisk)
			coordinator?.userDidCompletePages(hasScanLock: false)
		}
	}
}

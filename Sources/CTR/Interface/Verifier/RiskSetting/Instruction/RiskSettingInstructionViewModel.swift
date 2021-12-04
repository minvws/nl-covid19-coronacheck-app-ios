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
	
	private let userSettings: UserSettingsProtocol
	
	/// The title of the scene
	@Bindable private(set) var title: String
	
	@Bindable private(set) var header: String
	
	@Bindable private(set) var lowRiskTitle: String
	
	@Bindable private(set) var lowRiskSubtitle: String
	
	@Bindable private(set) var lowRiskAccessibilityLabel: String
	
	@Bindable private(set) var highRiskTitle: String
	
	@Bindable private(set) var highRiskSubtitle: String
	
	@Bindable private(set) var highRiskAccessibilityLabel: String
	
	@Bindable private(set) var moreButtonTitle: String
	
	@Bindable private(set) var primaryButtonTitle: String
	
	@Bindable private(set) var riskLevel: RiskLevel
	
	var selectRisk: RiskLevel {
		didSet {
			userSettings.scanRiskLevelValue = selectRisk
		}
	}
	
	init(
		coordinator: (ScanInstructionsCoordinatorDelegate & OpenUrlProtocol),
		userSettings: UserSettingsProtocol) {
		
		self.coordinator = coordinator
		self.userSettings = userSettings
		
		title = L.verifier_risksetting_firsttimeuse_title()
		header = L.verifier_risksetting_firsttimeuse_header()
		lowRiskTitle = L.verifier_risksetting_lowrisk_title()
		lowRiskSubtitle = L.verifier_risksetting_lowrisk_subtitle()
		lowRiskAccessibilityLabel = "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
		highRiskTitle = L.verifier_risksetting_highrisk_title()
		highRiskSubtitle = L.verifier_risksetting_highrisk_subtitle()
		highRiskAccessibilityLabel = "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
		moreButtonTitle = L.verifier_risksetting_readmore()
		primaryButtonTitle = L.verifierScaninstructionsButtonStartscanning()
		
		let selectedRisk = userSettings.scanRiskLevelValue
		riskLevel = selectedRisk
		selectRisk = selectedRisk
	}
	
	func showReadMore() {
		guard let url = URL(string: L.verifier_risksetting_readmore_url()) else { return }
		
		coordinator?.openUrl(url, inApp: true)
	}
	
	func startScanner() {
		
		coordinator?.userDidCompletePages()
	}
}

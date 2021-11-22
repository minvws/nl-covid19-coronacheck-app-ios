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
		
		title = L.verifierRisksettingTitleInstruction()
		header = L.verifierRisksettingHeaderInstruction()
		lowRiskTitle = L.verifierRisksettingLowriskTitle()
		lowRiskSubtitle = L.verifierRisksettingLowriskSubtitle()
		lowRiskAccessibilityLabel = "\(L.verifierRisksettingLowriskTitle()), \(L.verifierRisksettingLowriskSubtitle())"
		highRiskTitle = L.verifierRisksettingHighriskTitle()
		highRiskSubtitle = L.verifierRisksettingHighriskSubtitle()
		highRiskAccessibilityLabel = "\(L.verifierRisksettingHighriskTitle()), \(L.verifierRisksettingHighriskSubtitle())"
		moreButtonTitle = L.verifierRisksettingReadmore()
		primaryButtonTitle = L.verifierScaninstructionsButtonStartscanning()
		
		let selectedRisk = userSettings.scanRiskLevelValue
		riskLevel = selectedRisk
		selectRisk = selectedRisk
	}
	
	func showReadMore() {
		guard let url = URL(string: L.verifierRisksettingReadmoreUrl()) else { return }
		
		coordinator?.openUrl(url, inApp: true)
	}
	
	func startScanner() {
		
		coordinator?.userDidCompletePages()
	}
}

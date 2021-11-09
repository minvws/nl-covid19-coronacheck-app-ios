/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class RiskSettingViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (Coordinator & OpenUrlProtocol)?
	
	private let userSettings: UserSettingsProtocol
	
	/// The title of the scene
	@Bindable private(set) var title: String
	
	@Bindable private(set) var header: String?
	
	@Bindable private(set) var lowRiskTitle: String?
	
	@Bindable private(set) var lowRiskSubtitle: String?
	
	@Bindable private(set) var highRiskTitle: String?
	
	@Bindable private(set) var highRiskSubtitle: String?
	
	@Bindable private(set) var moreButtonTitle: String?
	
	@Bindable private(set) var riskSetting: RiskSetting
	
	var selectRisk: RiskSetting {
		didSet {
			userSettings.scanRiskSettingValue = selectRisk
		}
	}
	
	init(
		coordinator: (Coordinator & OpenUrlProtocol),
		userSettings: UserSettingsProtocol) {
		
		self.coordinator = coordinator
		self.userSettings = userSettings
		
		title = L.verifierRisksettingTitle()
		header = L.verifierRisksettingHeaderMenuentry()
		lowRiskTitle = L.verifierRisksettingLowriskTitle()
		lowRiskSubtitle = L.verifierRisksettingLowriskSubtitle()
		highRiskTitle = L.verifierRisksettingHighriskTitle()
		highRiskSubtitle = L.verifierRisksettingHighriskSubtitle()
		moreButtonTitle = L.verifierRisksettingReadmore()
		
		let selectedRisk = userSettings.scanRiskSettingValue
		riskSetting = selectedRisk
		selectRisk = selectedRisk
	}
	
	func showReadMore() {
		guard let url = URL(string: L.verifierRisksettingReadmoreUrl()) else { return }
		
		coordinator?.openUrl(url, inApp: true)
	}
}

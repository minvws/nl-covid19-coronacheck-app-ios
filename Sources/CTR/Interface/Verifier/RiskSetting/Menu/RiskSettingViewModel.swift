/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class RiskSettingViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)?
	
	private let userSettings: UserSettingsProtocol
	
	/// The title of the scene
	@Bindable private(set) var title = L.verifier_risksetting_active_title()
	@Bindable private(set) var header = L.verifier_risksetting_firsttimeuse_header()
	@Bindable private(set) var lowRiskTitle = L.verifier_risksetting_lowrisk_title()
	@Bindable private(set) var lowRiskSubtitle = L.verifier_risksetting_lowrisk_subtitle()
	@Bindable private(set) var lowRiskAccessibilityLabel = "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
	@Bindable private(set) var highRiskTitle = L.verifier_risksetting_highrisk_title()
	@Bindable private(set) var highRiskSubtitle = L.verifier_risksetting_highrisk_subtitle()
	@Bindable private(set) var highRiskAccessibilityLabel = "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
	@Bindable private(set) var moreButtonTitle = L.verifier_risksetting_readmore()
	@Bindable private(set) var riskLevel: RiskLevel?
	
	var selectRisk: RiskLevel? {
		didSet {
			userSettings.scanRiskLevelValue = selectRisk
		}
	}
	
	init(
		coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol),
		userSettings: UserSettingsProtocol) {
		
		self.coordinator = coordinator
		self.userSettings = userSettings
		
		let selectedRisk = userSettings.scanRiskLevelValue
		riskLevel = selectedRisk
		selectRisk = selectedRisk
	}
	
	func showReadMore() {
		guard let url = URL(string: L.verifier_risksetting_readmore_url()) else { return }
		
		coordinator?.openUrl(url, inApp: true)
	}
}

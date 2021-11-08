/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class RiskSettingViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?
	
	/// The title of the scene
	@Bindable private(set) var title: String
	
	@Bindable private(set) var header: String?
	
	@Bindable private(set) var lowRiskTitle: String?
	
	@Bindable private(set) var lowRiskSubtitle: String?
	
	@Bindable private(set) var highRiskTitle: String?
	
	@Bindable private(set) var highRiskSubtitle: String?
	
	@Bindable private(set) var moreButtonTitle: String?
	
	init(coordinator: (VerifierCoordinatorDelegate & Dismissable)) {
		
		self.coordinator = coordinator
		
		title = L.verifierRisksettingTitle()
		header = L.verifierRisksettingHeaderMenuentry()
		lowRiskTitle = L.verifierRisksettingLowriskTitle()
		lowRiskSubtitle = L.verifierRisksettingLowriskSubtitle()
		highRiskTitle = L.verifierRisksettingHighriskTitle()
		highRiskSubtitle = L.verifierRisksettingHighriskSubtitle()
		moreButtonTitle = L.verifierRisksettingReadmore()
	}
}

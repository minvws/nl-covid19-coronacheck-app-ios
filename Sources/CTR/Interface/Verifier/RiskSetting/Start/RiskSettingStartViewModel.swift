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
	
	/// The title of the scene
	@Bindable private(set) var title: String = L.verifier_risksetting_start_title()
	
	@Bindable private(set) var header: String = L.verifier_risksetting_start_header()
	
	@Bindable private(set) var primaryTitle: String = L.verifier_risksetting_setting_button()
	
	init(coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)) {
		
	}
}

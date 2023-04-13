/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Models
import Resources

final class RiskSettingInstructionViewModel {
	
	/// Coordination Delegate
	weak private var coordinator: (ScanInstructionsCoordinatorDelegate & OpenUrlProtocol)?
	
	/// The title of the scene
	@Bindable private(set) var title = L.verifier_risksetting_firsttimeuse_title()
	@Bindable private(set) var header = L.verifier_risksetting_firsttimeuse_header()
	@Bindable private(set) var lowRiskTitle: String?
	@Bindable private(set) var lowRiskSubtitle = L.verifier_risksetting_subtitle_3G()
	@Bindable private(set) var lowRiskAccessibilityLabel: String?
	@Bindable private(set) var highRiskTitle: String?
	@Bindable private(set) var highRiskSubtitle = L.verifier_risksetting_subtitle_1G()
	@Bindable private(set) var highRiskAccessibilityLabel: String?
	@Bindable private(set) var moreButtonTitle = L.verifier_risksetting_readmore()
	@Bindable private(set) var primaryButtonTitle = L.verifierScaninstructionsButtonStartscanning()
	@Bindable private(set) var errorMessage = L.verification_policy_selection_error_message()
	@Bindable private(set) var shouldDisplayNotSetError = false
	@Bindable private(set) var verificationPolicy: VerificationPolicy?
	
	var selectVerificationPolicy: VerificationPolicy? {
		didSet {
			shouldDisplayNotSetError = false
		}
	}
	
	init(coordinator: (ScanInstructionsCoordinatorDelegate & OpenUrlProtocol)) {
		
		self.coordinator = coordinator
		
		let title3G = L.verifier_risksetting_title(VerificationPolicy.policy3G.localization)
		lowRiskTitle = title3G
		lowRiskAccessibilityLabel = "\(title3G), \(L.verifier_risksetting_subtitle_3G())"
		let title1G = L.verifier_risksetting_title(VerificationPolicy.policy1G.localization)
		highRiskTitle = title1G
		highRiskAccessibilityLabel = "\(title1G), \(L.verifier_risksetting_subtitle_1G())"
		
		let selectedVerificationPolicy = Current.verificationPolicyManager.state
		verificationPolicy = selectedVerificationPolicy
		selectVerificationPolicy = selectedVerificationPolicy
	}
	
	func showReadMore() {
		guard let url = URL(string: L.verifier_risksetting_readmore_url()) else { return }
		
		coordinator?.openUrl(url)
	}
	
	func startScanner() {
		
		if selectVerificationPolicy == nil {
			shouldDisplayNotSetError = true
		} else {
			Current.verificationPolicyManager.update(verificationPolicy: selectVerificationPolicy)
			coordinator?.userDidCompletePages(hasScanLock: false)
		}
	}
}

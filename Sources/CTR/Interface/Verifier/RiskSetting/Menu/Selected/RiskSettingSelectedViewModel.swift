/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class RiskSettingSelectedViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)?
	
	/// The title of the scene
	@Bindable private(set) var title = L.verifier_risksetting_active_title()
	@Bindable private(set) var header: String?
	@Bindable private(set) var lowRiskTitle: String?
	@Bindable private(set) var lowRiskSubtitle = L.verifier_risksetting_subtitle_3G()
	@Bindable private(set) var lowRiskAccessibilityLabel: String?
	@Bindable private(set) var highRiskTitle: String?
	@Bindable private(set) var highRiskSubtitle = L.verifier_risksetting_subtitle_1G()
	@Bindable private(set) var highRiskAccessibilityLabel: String?
	@Bindable private(set) var primaryButtonTitle = L.verifier_risksetting_confirmation_button()
	@Bindable private(set) var verificationPolicy: VerificationPolicy?
	@Bindable private(set) var alert: AlertContent?
	
	var selectVerificationPolicy: VerificationPolicy?
	private var scanLockMinutes: Int
	private var didWeRecentlyScanQRs: Bool = false

	init(
		coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)
	) {
		
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

		let scanLockSeconds = Current.remoteConfigManager.storedConfiguration.scanLockSeconds ?? 300
		scanLockMinutes = scanLockSeconds / 60

		guard let scanLock = Current.remoteConfigManager.storedConfiguration.scanLockWarningSeconds else { return }
		didWeRecentlyScanQRs = Current.scanLogManager.didWeScanQRs(withinLastNumberOfSeconds: scanLock)
		header = didWeRecentlyScanQRs ? L.verifier_risksetting_active_lock_warning_header(scanLockMinutes) : nil
	}
	
	func confirmSetting() {
		
		if didWeRecentlyScanQRs, verificationPolicy != selectVerificationPolicy {
			displayAlert()
		} else {
			saveSettingAndGoBackToStart(enablingLock: false)
		}
	}
}

private extension RiskSettingSelectedViewModel {
	
	func displayAlert() {

		alert = AlertContent(
			title: L.verifier_risksetting_confirmation_dialog_title(),
			subTitle: L.verifier_risksetting_confirmation_dialog_message(scanLockMinutes),
			cancelTitle: L.verifier_risksetting_confirmation_dialog_negative_button(),
			okAction: { [weak self] _ in
				self?.saveSettingAndGoBackToStart(enablingLock: true)
			},
			okTitle: L.verifier_risksetting_confirmation_dialog_positive_button(),
			okActionIsDestructive: true
		)
	}
	
	func saveSettingAndGoBackToStart(enablingLock: Bool) {
		if enablingLock {
			Current.scanLockManager.lock()
		}
		Current.verificationPolicyManager.update(verificationPolicy: selectVerificationPolicy)
		coordinator?.navigateToVerifierWelcome()
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class RiskSettingSelectedViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol)?
	
	private let riskLevelManager: RiskLevelManaging
	private let scanLogManager: ScanLogManaging
	private let scanLockManager: ScanLockManaging
	
	/// The title of the scene
	@Bindable private(set) var title = L.verifier_risksetting_active_title()
	@Bindable private(set) var header: String?
	@Bindable private(set) var lowRiskTitle = L.verifier_risksetting_lowrisk_title()
	@Bindable private(set) var lowRiskSubtitle = L.verifier_risksetting_lowrisk_subtitle()
	@Bindable private(set) var lowRiskAccessibilityLabel = "\(L.verifier_risksetting_lowrisk_title()), \(L.verifier_risksetting_lowrisk_subtitle())"
	@Bindable private(set) var highRiskTitle = L.verifier_risksetting_highrisk_title()
	@Bindable private(set) var highRiskSubtitle = L.verifier_risksetting_highrisk_subtitle()
	@Bindable private(set) var highRiskAccessibilityLabel = "\(L.verifier_risksetting_highrisk_title()), \(L.verifier_risksetting_highrisk_subtitle())"
	@Bindable private(set) var primaryButtonTitle = L.verifier_risksetting_confirmation_button()
	@Bindable private(set) var riskLevel: RiskLevel?
	@Bindable private(set) var alert: AlertContent?
	
	var selectRisk: RiskLevel?
	private var scanLockMinutes: Int
	private var didWeRecentlyScanQRs: Bool = false

	init(
		coordinator: (VerifierCoordinatorDelegate & OpenUrlProtocol),
		riskLevelManager: RiskLevelManaging = Services.riskLevelManager,
		scanLogManager: ScanLogManaging = Services.scanLogManager,
		scanLockManager: ScanLockManaging = Services.scanLockManager,
		configuration: RemoteConfiguration
	) {
		
		self.coordinator = coordinator
		self.riskLevelManager = riskLevelManager
		self.scanLogManager = scanLogManager
		self.scanLockManager = scanLockManager
		
		let selectedRisk = riskLevelManager.state
		riskLevel = selectedRisk
		selectRisk = selectedRisk

		let scanLockSeconds = configuration.scanLockSeconds ?? 300
		scanLockMinutes = scanLockSeconds / 60

		guard let scanLock = configuration.scanLockWarningSeconds else { return }
		didWeRecentlyScanQRs = scanLogManager.didWeScanQRs(withinLastNumberOfSeconds: scanLock)
		header = didWeRecentlyScanQRs ? L.verifier_risksetting_active_lock_warning_header(scanLockMinutes) : nil
	}
	
	func confirmSetting() {
		
		if didWeRecentlyScanQRs, riskLevel != selectRisk {
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
			scanLockManager.lock()
		}
		riskLevelManager.update(riskLevel: selectRisk)
		coordinator?.navigateToVerifierWelcome()
	}
}
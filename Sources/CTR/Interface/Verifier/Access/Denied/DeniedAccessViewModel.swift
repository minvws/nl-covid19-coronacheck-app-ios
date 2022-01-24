/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The access reasons
enum DeniedAccessReason: Equatable {

	case invalid
	case identityMismatch
}

final class DeniedAccessViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?
	
	/// The configuration
	private var configuration: ConfigurationGeneralProtocol = Configuration()
	
	/// A timer auto close the scene
	private var autoCloseTimer: Timer?
	
	/// The title of the scene
	@Bindable private(set) var accessTitle: String
	
	@Bindable private(set) var primaryTitle = L.verifierResultNext()
	
	@Bindable private(set) var secondaryTitle: String?
	
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable),
		deniedAccessReason: DeniedAccessReason
	) {
		
		self.coordinator = coordinator
		
		switch deniedAccessReason {
			case .invalid:
				accessTitle = L.verifierResultDeniedTitle()
				secondaryTitle = L.verifierResultDeniedReadmore()
			case .identityMismatch:
				accessTitle = L.verifier_result_denied_personal_data_mismatch_title()
		}
		
		addObservers()
	}
	
	deinit {
		
		stopAutoCloseTimer()
	}
	
	/// Start the auto close timer, close after configuration.getAutoCloseTime() seconds
	func startAutoCloseTimer() {

		guard autoCloseTimer == nil else {
			return
		}

		autoCloseTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(configuration.getAutoCloseTime()),
			target: self,
			selector: (#selector(autoCloseScene)),
			userInfo: nil,
			repeats: false
		)
	}
	
	func dismiss() {

		coordinator?.navigateToVerifierWelcome()
	}
	
	func scanAgain() {

		stopAutoCloseTimer()
		coordinator?.navigateToScan()
	}
	
	func showMoreInformation() {

		coordinator?.userWishesMoreInfoAboutDeniedQRScan()
	}
}

private extension DeniedAccessViewModel {
	
	// MARK: - AutoCloseTimer
	
	func addObservers() {

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(autoCloseScene),
			name: UIApplication.didEnterBackgroundNotification,
			object: nil
		)
	}

	func stopAutoCloseTimer() {

		autoCloseTimer?.invalidate()
		autoCloseTimer = nil
	}

	@objc func autoCloseScene() {

		logInfo("Auto closing the denied access view")
		stopAutoCloseTimer()
		scanAgain()
	}
}

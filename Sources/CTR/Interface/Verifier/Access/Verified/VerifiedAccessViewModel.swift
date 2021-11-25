/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The access options
enum VerifiedType: Equatable {

	case verified(RiskLevel)
	case demo(RiskLevel)
}

final class VerifiedAccessViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?
	
	/// A timer to go to scanner
	private var scanAgainTimer: Timer?
	
	/// The title of the scene
	@Bindable private(set) var accessTitle: String
	
	@Bindable private(set) var verifiedType: VerifiedType
	
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable),
		verifiedType: VerifiedType
	) {
		
		self.coordinator = coordinator
		self.verifiedType = verifiedType
		
		if case .verified(let risk) = verifiedType, risk.isHigh {
			accessTitle = L.verifierResultAccessTitleHighrisk()
		} else {
			accessTitle = L.verifierResultAccessTitle()
		}
		
		addObservers()
	}
	
	deinit {
		
		stopTimer()
	}
	
	func startScanAgainTimer() {

		guard scanAgainTimer == nil else { return }
		
		let displayTime: TimeInterval = 0.8
		let animationDuration = VerifierResultViewTraits.Animation.verifiedDuration

		scanAgainTimer = Timer.scheduledTimer(
			timeInterval: displayTime + animationDuration,
			target: self,
			selector: (#selector(scanAgainOrLaunchThirdPartyScannerApp)),
			userInfo: nil,
			repeats: false
		)
	}
	
	func dismiss() {

		stopTimer()
		coordinator?.navigateToVerifierWelcome()
	}
}

private extension VerifiedAccessViewModel {
	
	func addObservers() {

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(scanAgainOrLaunchThirdPartyScannerApp),
			name: UIApplication.didEnterBackgroundNotification,
			object: nil
		)
	}
	
	func stopTimer() {

		scanAgainTimer?.invalidate()
		scanAgainTimer = nil
	}
	
	@objc func scanAgainOrLaunchThirdPartyScannerApp() {
		
		stopTimer()
		coordinator?.userWishesToLaunchThirdPartyScannerApp()
	}
}

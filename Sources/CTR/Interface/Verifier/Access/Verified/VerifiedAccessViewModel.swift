/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The access options
enum VerifiedAccess: Equatable {

	case verified(VerificationPolicy)
	case demo(VerificationPolicy)
}

final class VerifiedAccessViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?
	
	/// A timer to go to scanner
	private var scanAgainTimer: Timer?
	
	/// The title of the scene
	@Bindable private(set) var accessTitle: String
	
	@Bindable private(set) var verifiedAccess: VerifiedAccess
	
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable),
		verifiedAccess: VerifiedAccess
	) {
		
		self.coordinator = coordinator
		self.verifiedAccess = verifiedAccess

		if Current.featureFlagManager.is1GPolicyEnabled() {
			switch verifiedAccess {
				case .verified(let verificationPolicy) where verificationPolicy == .policy1G,
						.demo(let verificationPolicy) where verificationPolicy == .policy1G:
					// TODO: Update title
					accessTitle = L.verifier_result_access_title_highrisk()
				default:
					accessTitle = L.verifier_result_access_title_lowrisk()
			}
		} else {
			switch verifiedAccess {
				case .verified:
					self.verifiedAccess = .verified(.policy3G)
				case .demo:
					self.verifiedAccess = .demo(.policy3G)
			}
			accessTitle = L.verifier_result_access_title()
		}
		
		addObservers()
	}
	
	deinit {
		
		stopTimer()
	}
	
	func startScanAgainTimer() {

		guard scanAgainTimer == nil else { return }
		
		let displayTime: TimeInterval = 0.8
		let animationDuration = VerifiedAccessViewTraits.Animation.verifiedDuration

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

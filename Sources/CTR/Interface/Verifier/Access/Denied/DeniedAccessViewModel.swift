/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

final class DeniedAccessViewModel {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?
	
	/// The configuration
	private var configuration: ConfigurationGeneralProtocol = Configuration()
	
	/// A timer auto close the scene
	private var autoCloseTimer: Timer?
	
	/// The title of the scene
	@Bindable private(set) var accessTitle = L.verifierResultDeniedTitle()
	
	@Bindable private(set) var primaryTitle = L.verifierResultNext()
	
	@Bindable private(set) var secondaryTitle = L.verifierResultDeniedReadmore()
	
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable)
	) {
		
		self.coordinator = coordinator
		
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

		autoCloseTimer = Timer.scheduledTimer(withTimeInterval: configuration.getAutoCloseTime(), repeats: false, block: { [weak self] _ in
			self?.autoCloseScene()
		})
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

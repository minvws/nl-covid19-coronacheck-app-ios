/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DeniedAccessViewModel: Logging {
	
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
	
	init(coordinator: (VerifierCoordinatorDelegate & Dismissable)) {
		
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

		// By default, unordered lists have a space above them in HTML
		let bulletSpacing: CGFloat = -24
		let spacing: CGFloat = 16

		let firstParagraph = Services.featureFlagManager.isVerificationPolicyEnabled() ? L.verifierDeniedMessageOne_2g() : L.verifierDeniedMessageOne()
		let textViews = [(TextView(htmlText: firstParagraph), spacing),
						 (TextView(htmlText: L.verifierDeniedMessageTwo()), bulletSpacing),
						 (TextView(htmlText: L.verifierDeniedMessageThree()), spacing),
						 (TextView(htmlText: L.verifierDeniedMessageFour()), 0),
						 (TextView(htmlText: L.verifierDeniedMessageFive()), spacing),
						 (TextView(htmlText: L.verifierDeniedMessageSix()), spacing)]

		coordinator?.displayContent(
			title: L.verifierDeniedTitle(),
			content: textViews
		)
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

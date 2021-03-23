/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class EnlargedQRViewModel: PreventableScreenCapture, Logging {

	/// The logging category
	var loggingCategory: String = "EnlargedQRViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The proof validator
	var proofValidator: ProofValidatorProtocol

	/// The configuration
	weak var configuration: ConfigurationGeneralProtocol?

	/// the notification center
	var notificationCenter: NotificationCenterProtocol = NotificationCenter.default

	/// The previous brightness
	var previousBrightness: CGFloat?

	/// A timer to keep the QR refreshed
	weak var validityTimer: Timer?

	/// The cl signed test proof
	@Bindable private(set) var qrMessage: Data?

	/// Show a valid QR Message
	@Bindable private(set) var showValidQR: Bool

	/// Show a warning for a screenshot
	@Bindable private(set) var showScreenshotWarning: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	///   - proofManager: the proof manager
	///   - configuration: the configuration
	///   - maxValidity: the maximum validity of a test in hours
	init(
		coordinator: HolderCoordinatorDelegate,
		cryptoManager: CryptoManaging,
		proofManager: ProofManaging,
		configuration: ConfigurationGeneralProtocol,
		maxValidity: Int) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager
		self.proofManager = proofManager
		self.configuration = configuration

		// Start by showing nothing
		self.showValidQR = false

		self.proofValidator = ProofValidator(maxValidity: maxValidity)
		super.init()
		addObserver()
	}

	/// Check the QR Validity
	@objc func checkQRValidity() {

		guard let credential = cryptoManager?.readCredential() else {
			coordinator?.navigateBackToStart()
			return
		}

		if let sampleTimeStamp = TimeInterval(credential.sampleTime) {

			switch proofValidator.validate(sampleTimeStamp) {
				case let .valid(validUntilDate):
					logDebug("Proof is valid until \(validUntilDate)")
					showQRMessageIsValid()
					startValidityTimer()
				case let .expiring(validUntilDate, _):
					logDebug("Proof is valid until \(validUntilDate)")
					showQRMessageIsValid()
					startValidityTimer()
				case .expired:
					logDebug("Proof is no longer valid")
					validityTimer?.invalidate()
					validityTimer = nil
					coordinator?.navigateBackToStart()
			}
		}
	}

	/// Adjust the brightness
	/// - Parameter reset: True if we reset to previous value
	func setBrightness(reset: Bool = false) {

		let currentBrightness = UIScreen.main.brightness
		if currentBrightness < 1 {
			previousBrightness = currentBrightness
		}

		UIScreen.main.brightness = reset ? previousBrightness ?? 1 : 1
	}

	/// Show the QR message is valid
	func showQRMessageIsValid() {

		if let message = self.cryptoManager?.generateQRmessage() {
			qrMessage = message
			showValidQR = true
		}
	}

	/// Start the validity timer, check every 90 seconds.
	func startValidityTimer() {

		guard validityTimer == nil, let configuration = configuration else {
			return
		}

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(configuration.getQRTTL() / 2),
			target: self,
			selector: (#selector(checkQRValidity)),
			userInfo: nil,
			repeats: true
		)
	}

	/// Add an observer for the userDidTakeScreenshotNotification notification
	func addObserver() {

		notificationCenter.addObserver(
			self,
			selector: #selector(handleScreenShot),
			name: UIApplication.userDidTakeScreenshotNotification,
			object: nil
		)
	}

	/// handle a screen shot taken
	@objc func handleScreenShot() {

		showScreenshotWarning = true
	}
}

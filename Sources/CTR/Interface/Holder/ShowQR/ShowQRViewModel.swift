/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class ShowQRViewModel: PreventableScreenCapture, Logging {

	var loggingCategory: String = "ShowQRViewModel"

	weak var coordinator: HolderCoordinatorDelegate?

	weak var cryptoManager: CryptoManaging?

	weak var configuration: ConfigurationGeneralProtocol?

	var notificationCenter: NotificationCenterProtocol = NotificationCenter.default

	var previousBrightness: CGFloat?

	weak var validityTimer: Timer?

	var greenCard: GreenCard

	@Bindable private(set) var title: String

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
	///   - configuration: the configuration
	///   - maxValidity: the maximum validity of a test in hours
	init(
		coordinator: HolderCoordinatorDelegate,
		greenCard: GreenCard,
		cryptoManager: CryptoManaging,
		configuration: ConfigurationGeneralProtocol) {

		self.coordinator = coordinator
		self.greenCard = greenCard
		self.cryptoManager = cryptoManager
		self.configuration = configuration

		// Start by showing nothing
		self.showValidQR = false

		title = greenCard.type == GreenCardType.domestic.rawValue ? .holderShowQRDomesticTitle : .holderShowQREuTitle

		super.init()
		addObserver()
	}

	/// Check the QR Validity
	@objc func checkQRValidity() {

		guard let credential = greenCard.getActiveCredential(),
			  let data = credential.data,
			  let expirationTime = credential.expirationTime, expirationTime > Date() else {
			setQRNotValid()
			return
		}

		if greenCard.type == GreenCardType.domestic.rawValue {
			if let message = self.cryptoManager?.generateQRmessage(data) {
				setQRValid(message)
			} else {
				setQRNotValid()
				return
			}
		} else {
			setQRValid(data)
		}
	}

	private func setQRValid(_ data: Data) {

		logDebug("Credential is valid")
		qrMessage = data
		showValidQR = true
		startValidityTimer()
	}

	private func setQRNotValid() {

		logDebug("Credential is not valid")
		qrMessage = nil
		showValidQR = false
		stopValidityTimer()
		coordinator?.navigateBackToStart()
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

	/// Start the validity timer, check every 90 seconds.
	private func startValidityTimer() {

		guard validityTimer == nil, let configuration = configuration else {
			return
		}

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(configuration.getQRRefreshPeriod()),
			target: self,
			selector: (#selector(checkQRValidity)),
			userInfo: nil,
			repeats: true
		)
	}

	func stopValidityTimer() {
		validityTimer?.invalidate()
		validityTimer = nil
	}

	/// Add an observer for the userDidTakeScreenshotNotification notification
	private func addObserver() {

		notificationCenter.addObserver(
			self,
			selector: #selector(handleScreenShot),
			name: UIApplication.userDidTakeScreenshotNotification,
			object: nil
		)
	}

	/// handle a screen shot taken
	@objc internal func handleScreenShot() {

		showScreenshotWarning = true
	}
}

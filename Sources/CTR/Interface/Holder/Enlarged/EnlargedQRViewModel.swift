/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class EnlargedQRViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "EnlargedQRViewModel"

	/// Coordination Delegate
	weak var coordinator: Dismissable?

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The proof validator
	var proofValidator: ProofValidatorProtocol

	/// The configuration
	weak var configuration: ConfigurationGeneralProtocol?

	/// The previous brightness
	var previousBrightness: CGFloat?

	/// A timer to keep the QR refreshed
	weak var validityTimer: Timer?

	/// The message above the QR card
	@Bindable private(set) var qrTitle: String?

	/// The message below the QR card
	@Bindable private(set) var qrSubTitle: String?

	/// The cl signed test proof
	@Bindable private(set) var qrMessage: Data?

	/// Show a valid QR Message
	@Bindable private(set) var showValidQR: Bool

	/// Hide for screen capture
	@Bindable var hideQRForCapture: Bool

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	///   - proofManager: the proof manager
	///   - configuration: the configuration
	///   - maxValidity: the maximum validity of a test in hours
	init(
		coordinator: Dismissable,
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
		self.hideQRForCapture = false

		self.proofValidator = ProofValidator(maxValidity: maxValidity)
		self.addObserver()
	}

	/// Check the QR Validity
	@objc func checkQRValidity() {

		guard let credential = cryptoManager?.readCredential() else {
			coordinator?.dismiss()
			return
		}

		if let sampleTimeStamp = TimeInterval(credential.sampleTime) {

			switch proofValidator.validate(sampleTimeStamp) {
				case let .valid(validUntilDate):
					let validUntilDateString = printDateFormatter.string(from: validUntilDate)
					logDebug("Proof is valid until \(validUntilDateString)")
					showQRMessageIsValid(validUntilDateString)
					startValidityTimer()
				case .expired:
					logDebug("Proof is no longer valid")
					validityTimer?.invalidate()
					validityTimer = nil
					coordinator?.dismiss()
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
	/// - Parameter printDate: valid until time
	func showQRMessageIsValid(_ printDate: String) {

		if let message = self.cryptoManager?.generateQRmessage() {
			qrMessage = message
			qrSubTitle = String(format: .holderDashboardQRMessage, printDate)
			showValidQR = true
		}
		if let birthdate = proofManager?.getBirthDate() {
			qrTitle = printBirthDateFormatter.string(from: birthdate)
		}
	}

	/// Start the validity timer, check every 170 seconds.
	func startValidityTimer() {

		guard validityTimer == nil, let configuration = configuration else {
			return
		}

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(configuration.getQRTTL() - 10),
			target: self,
			selector: (#selector(checkQRValidity)),
			userInfo: nil,
			repeats: true
		)
	}

	func dismiss() {

		coordinator?.dismiss()
	}

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "CET")
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "E d MMMM HH:mm"
		return dateFormatter
	}()

	/// Formatter to print
	private lazy var printBirthDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "dd-MM-yyyy"
		return dateFormatter
	}()
}

// MARK: - capturedDidChangeNotification

extension EnlargedQRViewModel {

	/// Add an observer for the capturedDidChangeNotification
	func addObserver() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(preventScreenCapture),
			name: UIScreen.capturedDidChangeNotification,
			object: nil
		)
	}

	/// Prevent screen capture
	@objc func preventScreenCapture() {

		if UIScreen.main.isCaptured {
			hideQRForCapture = true
			self.logWarning("Screen capture in progress")
		} else {
			hideQRForCapture = false
		}
	}
}

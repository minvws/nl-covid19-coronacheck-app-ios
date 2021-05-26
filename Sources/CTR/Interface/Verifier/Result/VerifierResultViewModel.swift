/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The access options
enum AccessAction {

	case verified
	case denied
	case demo
}

class VerifierResultViewModel: PreventableScreenCapture, Logging {

	/// The logging category
	var loggingCategory: String = "VerifierResultViewModel"

	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?

	/// The configuration
	private var configuration: ConfigurationGeneralProtocol = Configuration()

	/// The proof validator
	private var proofValidator: ProofValidatorProtocol

	/// The scanned attributes
	internal var cryptoResults: (attributes: Attributes?, errorMessage: String?)

	/// A timer auto close the scene
	private var autoCloseTimer: Timer?

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String = ""

	/// The message of the scene
	@Bindable private(set) var message: String?

	/// The first name of the holder
	@Bindable private(set) var firstName: String = "-"

	/// The last name of the holder
	@Bindable private(set) var lastName: String = "-"

	/// The birth day of the holder
	@Bindable private(set) var dayOfBirth: String = "-"

	/// The birth mont of the holder
	@Bindable private(set) var monthOfBirth: String = "-"

	/// The linked message of the scene
	@Bindable var linkedMessage: String?

	/// The title of the button
	@Bindable private(set) var primaryButtonTitle: String

	/// Allow Access?
	@Bindable var allowAccess: AccessAction = .denied

	/// Initialzier
	/// - Parameters:
	///   - coordinator: the dismissable delegate
	///   - scanResults: the decrypted attributes
	///   - maxValidity: the maximum validity of a test in hours
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable),
		cryptoResults: (Attributes?, String?),
		maxValidity: Int) {

		self.coordinator = coordinator
		self.cryptoResults = cryptoResults

		proofValidator = ProofValidator(maxValidity: maxValidity)
		primaryButtonTitle = .verifierResultButtonTitle
		super.init()

		checkAttributes()
		startAutoCloseTimer()
	}

	override func addObservers() {

		// super will handle the PreventableScreenCapture observers
		super.addObservers()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(autoCloseScene),
			name: UIApplication.didEnterBackgroundNotification,
			object: nil
		)
	}

	deinit {

		stopAutoCloseTimer()
	}

	/// Check the attributes
	internal func checkAttributes() {

		guard let attributes = cryptoResults.attributes else {
			allowAccess = .denied
			showAccessDenied()
			return
		}
		
		/// The time is now!
		let now = Date().timeIntervalSince1970

		if isQRTimeStampValid(now, attributes: attributes) && isSampleTimeValid(now, attributes: attributes) {

			setHolderIdentity(attributes)
			if attributes.cryptoAttributes.isSpecimen {
				allowAccess = .demo
				showAccessDemo()
			} else {
				allowAccess = .verified
				showAccessAllowed()
			}

		} else {

			allowAccess = .denied
			showAccessDenied()
		}
	}

	func setHolderIdentity(_ attributes: Attributes) {

		firstName = determineAttributeValue(attributes.cryptoAttributes.firstNameInitial)
		lastName = determineAttributeValue(attributes.cryptoAttributes.lastNameInitial)
		dayOfBirth = determineAttributeValue(attributes.cryptoAttributes.birthDay)
		monthOfBirth = determineMonthOfBirth(attributes.cryptoAttributes.birthMonth)
	}

	/// Determine the value for display
	/// - Parameter value: the crypto attribute value
	/// - Returns: the value of the attribute, or a hyphen if empty
	private func determineAttributeValue(_ value: String?) -> String {

		if let value = value, !value.isEmpty {
			return value
		}
		return "-"
	}

	/// Set the monthOfBirth as MMM (mm)
	/// - Parameter value: the possible month value
	private func determineMonthOfBirth(_ value: String?) -> String {

		if let birthMonthAsString = value, !birthMonthAsString.isEmpty {
			if let birthMonthAsInt = Int(birthMonthAsString),
			   let month = mapMonth(month: birthMonthAsInt, months: String.shortMonths) {

				let formatter = NumberFormatter()
				formatter.minimumIntegerDigits = 2
				if let monthWithLeadingZero = formatter.string(from: NSNumber(value: birthMonthAsInt)) {
					return month + " (\(monthWithLeadingZero))"
				}
			} else {
				return birthMonthAsString
			}
		}
		return "-"
	}

	private func mapMonth(month: Int, months: [String]) -> String? {

		if month <= months.count, month > 0 {
			return months[month - 1]
		}
		return nil
	}

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "E d MMMM HH:mm:ss"
		return dateFormatter
	}()

	/// Is the sample time still valid?
	/// - Parameter now: the now time stamp
	/// - Returns: True if the sample time stamp is still valid
	private func isSampleTimeValid(_ now: TimeInterval, attributes: Attributes) -> Bool {

		if let sampleTimeStamp = TimeInterval(attributes.cryptoAttributes.sampleTime) {
			switch proofValidator.validate(sampleTimeStamp) {
				case .valid, .expiring:
					return true
				case .expired:
					logInfo("Sample Timestamp is too old!")
					return false
			}
		}
		logInfo("no Sample Timestamp")
		return false
	}

	/// Is the QR timestamp stil valid?
	/// - Parameter now: the now timestamp
	/// - Returns: True if the QR time stamp is still valid
	private func isQRTimeStampValid(_ now: TimeInterval, attributes: Attributes) -> Bool {

		guard !attributes.cryptoAttributes.isPaperProof else {
			logInfo("this is a paper proof, ignore QR Timestamp")
			return true
		}

		let absoluteQRTimeDifference = abs(now - TimeInterval(attributes.unixTimeStamp))
		if absoluteQRTimeDifference < configuration.getQRGracePeriod() {
			logDebug("QR Timestamp within period: \(absoluteQRTimeDifference)")
			return true
		}

		logInfo("QR Timestamp is too old!")
		return false
	}

	private func showAccessAllowed() {

		title = .verifierResultAccessTitle
		message = nil
	}

	private func showAccessDenied() {

		title = .verifierResultDeniedTitle
		message = .verifierResultDeniedMessage
		linkedMessage = .verifierResultDeniedLink
	}

	private func showAccessDemo() {

		title = .verifierResultDemoTitle
		message = nil
	}

	func dismiss() {

		stopAutoCloseTimer()
		coordinator?.navigateToVerifierWelcome()
	}

    func scanAgain() {

		stopAutoCloseTimer()
        coordinator?.navigateToScan()
    }

	func linkTapped() {

		switch allowAccess {
			case .verified, .demo:
				showVerifiedInfo()
			case .denied:
				showDeniedInfo()
		}
	}

	private func showVerifiedInfo() {

		let label = Label(body: nil).multiline()
		label.attributedText = .makeFromHtml(
			text: .verifierResultCheckText,
			font: Theme.fonts.body,
			textColor: Theme.colors.dark
		)

		coordinator?.displayContent(
			title: .verifierResultCheckTitle,
			content: [(label, 16)]
		)
	}

	private func showDeniedInfo() {

		let label = Label(body: nil).multiline()
		label.attributedText = .makeFromHtml(
			text: .verifierDeniedMessageOne,
			font: Theme.fonts.body,
			textColor: Theme.colors.dark
		)

		let label2 = Label(body: nil).multiline()
		label2.attributedText = .makeFromHtml(
			text: .verifierDeniedMessageTwo,
			font: Theme.fonts.body,
			textColor: Theme.colors.dark
		)

		coordinator?.displayContent(
			title: .verifierDeniedTitle,
			content: [(label, 16), (label2, 0)]
		)
	}

	// MARK: - AutoCloseTimer

	/// Start the auto close timer, close after configuration.getAutoCloseTime() seconds
	private func startAutoCloseTimer() {

		guard autoCloseTimer == nil else {
			return
		}

		autoCloseTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(configuration.getAutoCloseTime()),
			target: self,
			selector: (#selector(autoCloseScene)),
			userInfo: nil,
			repeats: true
		)
	}

	private func stopAutoCloseTimer() {

		autoCloseTimer?.invalidate()
		autoCloseTimer = nil
	}

	@objc private func autoCloseScene() {

		logInfo("Auto closing the result view")
		stopAutoCloseTimer()
		dismiss()
	}
}

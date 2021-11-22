/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Clcore

/// The access options
enum AccessAction {

	case verified
	case denied
	case demo
}

class VerifierResultViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "VerifierResultViewModel"

	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?

	/// The configuration
	private var configuration: ConfigurationGeneralProtocol = Configuration()

	/// The scanned result
	internal var verificationResult: MobilecoreVerificationResult
	
	private var isDeepLinkEnabled: Bool

	/// A timer auto close the scene
	private var autoCloseTimer: Timer?

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String = ""

	/// The first name of the holder
	@Bindable private(set) var firstName: String?

	/// The last name of the holder
	@Bindable private(set) var lastName: String?

	/// The birth day of the holder
	@Bindable private(set) var dayOfBirth: String?

	/// The birth mont of the holder
	@Bindable private(set) var monthOfBirth: String?
	
	@Bindable private(set) var primaryTitle: String = ""
	
	@Bindable private(set) var secondaryTitle: String = ""
	
	@Bindable private(set) var dccFlag: String?
	
	@Bindable private(set) var dccScanned: String?
	
	@Bindable private(set) var checkIdentity: String = ""
	
	@Bindable private(set) var primaryButtonIcon: UIImage?
	
	@Bindable private(set) var verifiedAccessibility: String?

	/// Allow Access?
	@Bindable var allowAccess: AccessAction = .denied

	@Bindable private(set) var hideForCapture: Bool = false

	private let screenCaptureDetector = ScreenCaptureDetector()

	/// Initialzier
	/// - Parameters:
	///   - coordinator: The dismissable delegate
	///   - verificationResult: The verification result
	///   - hasDeepLinkEnabled: Deeplink boolean
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable),
		verificationResult: MobilecoreVerificationResult,
		isDeepLinkEnabled: Bool) {

		self.coordinator = coordinator
		self.verificationResult = verificationResult
		self.isDeepLinkEnabled = isDeepLinkEnabled

		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.hideForCapture = isBeingCaptured
		}

		addObservers()
		checkAttributes()
	}

	func addObservers() {

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
		
		guard verificationResult.status == MobilecoreVERIFICATION_SUCCESS else {
			allowAccess = .denied
			showAccessDeniedInvalidQR()
			return
		}
		
		guard let details = verificationResult.details else {
			allowAccess = .denied
			showAccessDeniedInvalidQR()
			return
		}

		if details.isSpecimen == "1" {
			allowAccess = .demo
			setHolderIdentity(details)
			showAccessDemo()
		} else {
			allowAccess = .verified
			setHolderIdentity(details)
			showAccessAllowed()
		}
	}

	func setHolderIdentity(_ details: MobilecoreVerificationDetails) {

		firstName = determineAttributeValue(details.firstNameInitial)
		lastName = determineAttributeValue(details.lastNameInitial)
		dayOfBirth = determineAttributeValue(details.birthDay)
		monthOfBirth = determineMonthOfBirth(details.birthMonth)
	}

	/// Determine the value for display
	/// - Parameter value: the crypto attribute value
	/// - Returns: the value of the attribute, or a hyphen if empty
	private func determineAttributeValue(_ value: String?) -> String? {

		if let value = value, !value.isEmpty {
			return value
		}
		return nil
	}

	/// Set the monthOfBirth as MMM (mm)
	/// - Parameter value: the possible month value
	private func determineMonthOfBirth(_ value: String?) -> String? {

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
		return nil
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

	private func showAccessAllowed() {

		title = L.verifierResultAccessTitle()
		primaryTitle = L.verifierResultAccessIdentityverified()
		secondaryTitle = L.verifierResultAccessReadmore()
		checkIdentity = L.verifierResultAccessCheckidentity()
		primaryButtonIcon = isDeepLinkEnabled ? I.deeplinkScan() : nil
		showDccInfo()
		verifiedAccessibility = "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
	}

	private func showAccessDeniedInvalidQR() {

		title = L.verifierResultDeniedTitle()
		primaryTitle = L.verifierResultNext()
		secondaryTitle = L.verifierResultDeniedReadmore()
	}

	private func showAccessDemo() {

		title = L.verifierResultDemoTitle()
		primaryTitle = L.verifierResultAccessIdentityverified()
		secondaryTitle = L.verifierResultAccessReadmore()
		checkIdentity = L.verifierResultAccessCheckidentity()
		primaryButtonIcon = isDeepLinkEnabled ? I.deeplinkScan() : nil
		showDccInfo()
		verifiedAccessibility = "\(L.verifierResultAccessAccessibilityDemo()), \(L.verifierResultIdentityTitle())"
	}

	func dismiss() {

		stopAutoCloseTimer()
		coordinator?.navigateToVerifierWelcome()
	}

    func scanAgain() {

		stopAutoCloseTimer()
        coordinator?.navigateToScan()
    }
	
	func launchThirdPartyAppOrScanAgain() {
		
		stopAutoCloseTimer()
		coordinator?.userWishesToLaunchThirdPartyScannerApp()
	}

	func showMoreInformation() {

		switch allowAccess {
			case .verified, .demo:
				showVerifiedInfo()
			case .denied:
				showDeniedInfo()
		}
	}
	
	func showVerified() {
		
		stopAutoCloseTimer()
		
		let displayDuration: CGFloat = 0.8
		let verifiedDuration = VerifierResultViewTraits.Animation.verifiedDuration
		
		DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration + verifiedDuration) {
			
			self.launchThirdPartyAppOrScanAgain()
		}
	}

	private func showVerifiedInfo() {

		stopAutoCloseTimer()
		coordinator?.navigateToVerifiedInfo()
	}

	private func showDeniedInfo() {
		
		// By default, unordered lists have a space above them in HTML
		let bulletSpacing: CGFloat = -26
		let spacing: CGFloat = 16

		let textViews = [(TextView(htmlText: L.verifierDeniedMessageOne()), spacing),
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
	
	private func showDccInfo() {
		
		// Continue when a value is available
		guard var countryCode = verificationResult.details?.issuerCountryCode else { return }
		
		// Do not display for domestic result
		guard countryCode.caseInsensitiveCompare("NL") != .orderedSame else { return }
		
		// Set DCC description
		dccScanned = L.verifierResultAccessDcc()
		
		// Uppercased for proper unicode scalar value
		countryCode = countryCode.uppercased()
		
		// Check character count. Empty string and ISO 3166-1 alpha-2 codes are allowed.
		guard countryCode == "" || countryCode.count == 2 else { return }
		
		// Check for valid country code
		guard Locale.isoRegionCodes.contains(where: { $0 == countryCode }) else { return }
		
		// Set flag
		dccFlag = flag(country: countryCode)
	}
	
	/// Get emoji country flag for two character country code
	/// - Parameter country: The country code
	/// - Returns: Emoji country flag
	private func flag(country: String) -> String? {
		
		let base: UInt32 = 127397
		var scalars = ""
		for scalar in country.unicodeScalars {
			scalars.unicodeScalars.append(UnicodeScalar(base + scalar.value)!)
		}
		let flag = String(scalars)
		return flag.isEmpty ? nil : flag
	}

	// MARK: - AutoCloseTimer

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
		scanAgain()
	}
}

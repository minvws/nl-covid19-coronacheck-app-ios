/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Clcore

final class CheckIdentityViewModel: Logging {
	
	/// Coordination Delegate
	weak private var coordinator: (VerifierCoordinatorDelegate & Dismissable)?

	/// The configuration
	private var configuration: ConfigurationGeneralProtocol = Configuration()
	
	/// The scanned details
	internal var verificationDetails: MobilecoreVerificationDetails
	
	private var isDeepLinkEnabled: Bool
	
	private let screenCaptureDetector = ScreenCaptureDetector()
	
	/// A timer auto close the scene
	private var autoCloseTimer: Timer?
	
	@Bindable private(set) var hideForCapture: Bool = false
	
	@Bindable private(set) var title: String
	
	/// The first name of the holder
	@Bindable private(set) var firstName: String?

	/// The last name of the holder
	@Bindable private(set) var lastName: String?

	/// The birth day of the holder
	@Bindable private(set) var dayOfBirth: String?

	/// The birth mont of the holder
	@Bindable private(set) var monthOfBirth: String?
	
	@Bindable private(set) var primaryTitle: String
	
	@Bindable private(set) var secondaryTitle: String
	
	@Bindable private(set) var dccFlag: String?
	
	@Bindable private(set) var dccScanned: String?
	
	@Bindable private(set) var checkIdentity: String
	
	@Bindable private(set) var primaryButtonIcon: UIImage?
	
	@Bindable private(set) var verifiedAccessibility: String
	
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable),
		verificationDetails: MobilecoreVerificationDetails,
		isDeepLinkEnabled: Bool
	) {
		
		self.coordinator = coordinator
		self.verificationDetails = verificationDetails
		self.isDeepLinkEnabled = isDeepLinkEnabled
		
		title = L.verifierResultIdentityTitle()
		primaryTitle = L.verifierResultAccessIdentityverified()
		secondaryTitle = L.verifierResultAccessReadmore()
		checkIdentity = L.verifierResultAccessCheckidentity()
		verifiedAccessibility = "\(L.verifierResultAccessAccessibilityVerified()), \(L.verifierResultIdentityTitle())"
		
		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.hideForCapture = isBeingCaptured
		}
		
		addObservers()
		setHolderIdentity(verificationDetails)
		primaryButtonIcon = isDeepLinkEnabled ? I.deeplinkScan() : nil
		showDccInfo()
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

		stopAutoCloseTimer()
		coordinator?.navigateToVerifierWelcome()
	}
	
	func scanAgain() {

		stopAutoCloseTimer()
		coordinator?.navigateToScan()
	}
	
	func showVerifiedAccess() {
		
		stopAutoCloseTimer()
		coordinator?.navigateToVerifiedAccess()
	}
	
	func showMoreInformation() {

		stopAutoCloseTimer()
		coordinator?.navigateToVerifiedInfo()
	}
}

private extension CheckIdentityViewModel {
	
	func setHolderIdentity(_ details: MobilecoreVerificationDetails) {

		firstName = determineAttributeValue(details.firstNameInitial)
		lastName = determineAttributeValue(details.lastNameInitial)
		dayOfBirth = determineAttributeValue(details.birthDay)
		monthOfBirth = determineMonthOfBirth(details.birthMonth)
	}

	/// Determine the value for display
	/// - Parameter value: the crypto attribute value
	/// - Returns: the value of the attribute, or a hyphen if empty
	func determineAttributeValue(_ value: String?) -> String? {

		if let value = value, !value.isEmpty {
			return value
		}
		return nil
	}

	/// Set the monthOfBirth as MMM (mm)
	/// - Parameter value: the possible month value
	func determineMonthOfBirth(_ value: String?) -> String? {

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

	func mapMonth(month: Int, months: [String]) -> String? {

		if month <= months.count, month > 0 {
			return months[month - 1]
		}
		return nil
	}
	
	// MARK: - DCC Flag
	
	/// Get emoji country flag for two character country code
	/// - Parameter country: The country code
	/// - Returns: Emoji country flag
	func flag(country: String) -> String? {
		
		let base: UInt32 = 127397
		var scalars = ""
		for scalar in country.unicodeScalars {
			scalars.unicodeScalars.append(UnicodeScalar(base + scalar.value)!)
		}
		let flag = String(scalars)
		return flag.isEmpty ? nil : flag
	}
	
	func showDccInfo() {
		
		// Get issuer country code
		var countryCode = verificationDetails.issuerCountryCode
		
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

		logInfo("Auto closing the check identity view")
		stopAutoCloseTimer()
		scanAgain()
	}
}

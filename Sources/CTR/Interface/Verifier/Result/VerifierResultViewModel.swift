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

class VerifierResultViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "VerifierResultViewModel"

	/// Coordination Delegate
	weak var coordinator: (VerifierCoordinatorDelegate & Dismissable)?

	/// The configuration
	var configuration: ConfigurationGeneralProtocol = Configuration()

	/// The proof validator
	var proofValidator: ProofValidatorProtocol

	/// The scanned attributes
	var attributes: Attributes

	// MARK: - Bindable properties

	/// The title of the scene
	@Bindable private(set) var title: String = ""

	/// The message of the scene
	@Bindable private(set) var message: String = ""

	/// The identity of the holder
	@Bindable private(set) var identity: [(String, String)] = []

	/// The linked message of the scene
	@Bindable var linkedMessage: String?

	/// The title of the button
	@Bindable private(set) var primaryButtonTitle: String

	/// Allow Access?
	@Bindable private(set) var allowAccess: AccessAction = .denied

	/// Initialzier
	/// - Parameters:
	///   - coordinator: the dismissable delegae
	///   - attributes: the decrypted attributes
	///   - maxValidity: the maximum validity of a test in hours
	init(
		coordinator: (VerifierCoordinatorDelegate & Dismissable),
		attributes: Attributes,
		maxValidity: Int) {

		self.coordinator = coordinator
		self.attributes = attributes
		self.proofValidator = ProofValidator(maxValidity: maxValidity)

		primaryButtonTitle = .verifierResultButtonTitle

		checkAttributes()
	}

	/// Check the attributes
	internal func checkAttributes() {

		guard !isDemoQR() else {
			allowAccess = .demo
			showAccessDemo()
			return
		}

		/// The time is now!
		let now = Date().timeIntervalSince1970
		if isQRTimeStampValid(now) && isSampleTimeValid(now) {
			showAccessAllowed()
			allowAccess = .verified

			let holder = HolderTestCredentials(
				firstNameInitial: attributes.cryptoAttributes.firstNameInitial ?? "",
				lastNameInitial: attributes.cryptoAttributes.lastNameInitial ?? "",
				birthDay: attributes.cryptoAttributes.birthDay ?? "",
				birthMonth: attributes.cryptoAttributes.birthMonth ?? ""
			)
			let mapping = holder.mapIdentity(months: months)
			for element in mapping {
				identity.append(("", element.isEmpty ? "_" : element))
			}

		} else {
			showAccessDenied()
			allowAccess = .denied
		}
	}

	var months: [String] = [.shortJanuary, .shortFebruary, .shortMarch, .shortApril, .shortMay, .shortJune,
							.shortJuly, .shortAugust, .shortSeptember, .shortOctober, .shortNovember, .shortDecember]

	/// Is the sample time still valid
	/// - Parameter now: the now time stamp
	/// - Returns: True if the sample time stamp is still valid
	private func isSampleTimeValid(_ now: TimeInterval) -> Bool {

		if let sampleTimeStamp = TimeInterval(attributes.cryptoAttributes.sampleTime) {
			switch proofValidator.validate(sampleTimeStamp) {
				case .valid:
					return true
				case .expired:
					logInfo("Sample Timestamp is too old!")
					return false
			}
		}
		logInfo("no Sample Timestamp")
		return false
	}

	private func isDemoQR() -> Bool {

		return attributes.cryptoAttributes.testType.lowercased() == "demo"
	}

	/// Is the QR timestamp stil valid
	/// - Parameter now: the now timestamp
	/// - Returns: True if the QR time stamp is still valid
	private func isQRTimeStampValid(_ now: TimeInterval) -> Bool {

		if TimeInterval(attributes.unixTimeStamp) + configuration.getQRTTL() > now  &&
			TimeInterval(attributes.unixTimeStamp) <= now {
			return true
		}
		logInfo("QR Timestamp is too old!")
		return false
	}

	/// Show access allowed
	private func showAccessAllowed() {

		title = .verifierResultAccessTitle
		message =  .verifierResultAccessMessage
		linkedMessage = .verifierResultAccessLink
	}

	/// Show access denied
	private func showAccessDenied() {

		title = .verifierResultDeniedTitle
		message = .verifierResultDeniedMessage
		linkedMessage = .verifierResultDeniedLink
	}

	/// Show access allowed
	private func showAccessDemo() {

		title = .verifierResultDemoTitle
		message =  .verifierResultDemoMessage
		linkedMessage = nil
	}

	/// Dismiss ourselves
	func dismiss() {

		coordinator?.dismiss()
	}

	func linkTapped() {

		logDebug("Tapped on link")
//		coordinator?.presentInformationPage(
//			title: .verifierDeniedTitle,
//			body: .verifierDeniedMessage,
//			showBottomCloseButton: true
//		)
	}
}

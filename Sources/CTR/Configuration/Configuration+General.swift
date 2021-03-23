/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol ConfigurationGeneralProtocol: AnyObject {

	/// Get the TTL for a test result warning
	/// - Returns: TTL for a test result warning
	func getTestResultWarningTTL() -> Int

	/// Get the TTL for a QR
	/// - Returns: TTL for a QR
	func getQRTTL() -> TimeInterval

	/// Get the URL for the privacy policy
	/// - Returns: the privay policy url
	func getPrivacyPolicyURL() -> URL

	/// Get the URL for the holder about url
	/// - Returns: the holder about url
	func getHolderAboutAppURL() -> URL

	/// Get the URL for the holder faq
	/// - Returns: the holder faq uel
	func getHolderFAQURL() -> URL

	/// Get the URL for the verifier about url
	/// - Returns: the verifier about url
	func getVerifierAboutAppURL() -> URL

	/// Get the URL for the holder faq
	/// - Returns: the holder faq uel
	func getVerifierFAQURL() -> URL
}

// MARK: - ConfigurationGeneralProtocol

extension Configuration: ConfigurationGeneralProtocol {

	/// Get the TTL for a test result warning
	/// - Returns: TTL for a test result warning
	func getTestResultWarningTTL() -> Int {
		guard let value = general["testresultWarningTTL"] as? Int else {
			fatalError("Configuration: No Test Restult Warning TTL provided")
		}
		return value
	}

	/// Get the TTL for a QR
	/// - Returns: TTL for a QR
	func getQRTTL() -> TimeInterval {
		guard let value = general["QRTTL"] as? TimeInterval else {
			fatalError("Configuration: No QR TTL provided")
		}
		return value
	}

	/// Get the URL for the privacy policy
	/// - Returns: the privay policy url
	func getPrivacyPolicyURL() -> URL {
		guard let value = general["privacyPolicyURL"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No Privacy Policy URL provided")
		}
		return url
	}

	/// Get the URL for the holder about url
	/// - Returns: the holder about url
	func getHolderAboutAppURL() -> URL {
		guard let value = general["holderAboutURL"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No Holder About URL provided")
		}
		return url
	}

	/// Get the URL for the holder faq
	/// - Returns: the holder faq uel
	func getHolderFAQURL() -> URL {
		guard let value = general["holderFAQURL"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No Holder FAQ URL provided")
		}
		return url
	}

	/// Get the URL for the verifier about url
	/// - Returns: the verifier about url
	func getVerifierAboutAppURL() -> URL {
		guard let value = general["verifierAboutURL"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No Verifier About URL provided")
		}
		return url
	}

	/// Get the URL for the holder faq
	/// - Returns: the holder faq uel
	func getVerifierFAQURL() -> URL {
		guard let value = general["verifierFAQURL"] as? String,
			  let url = URL(string: value) else {
			fatalError("Configuration: No Verifier FAQ URL provided")
		}
		return url
	}
}

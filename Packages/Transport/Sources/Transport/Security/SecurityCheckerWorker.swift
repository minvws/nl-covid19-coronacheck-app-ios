/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Security
import Shared
import HTTPSecurity

class SecurityCheckerWorker {
	
	private let helper = TLSValidator()
	private let appTransportSecurityChecker = AppTransportSecurityChecker()
	
	func checkSSL(
		serverTrust: SecTrust,
		policies: [SecPolicy],
		trustedCertificates: [Data],
		hostname: String,
		trustedName: String?) -> Bool {
			
		guard appTransportSecurityChecker.check(
			serverTrust: serverTrust,
			policies: policies,
			trustedCertificates: trustedCertificates) else {
			logError("Bail on ATS")
			return false
		}
		
		guard trustedCertificates.isNotEmpty else {
			logVerbose("Skipping trustedCertificates check")
			return true
		}
			
		var validCertificate = false
		// No trusted name for providers. Use true if nil to bypass the check
		var validCommonNameEndsWithTrustedName = trustedName == nil ? true : false
		var validFQDN = false
		
		for index in 0 ..< SecTrustGetCertificateCount(serverTrust) {
			if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, index) {
				let serverCert = Certificate(certificate: serverCertificate)
				
				if let name = serverCert.commonName {
					logVerbose("Host Common Name: \(name)")
					validFQDN = validFQDN || checkFQDN(serverCert: serverCert, expectedName: hostname)
					validCommonNameEndsWithTrustedName = validCommonNameEndsWithTrustedName || checkCommonName(name, trustedName: trustedName)
				}
				if helper.validateSubjectAlternativeDNSName(hostname, for: serverCert.data) {
					validFQDN = true
					logVerbose("Host matched SAN \(hostname)")
				}
				validCertificate = validCertificate || checkCertificate(serverCert: serverCert, trustedCertificates: trustedCertificates)
			}
		}
		logVerbose("Server trust for \(hostname): validCert \(validCertificate), CN ending \(validCommonNameEndsWithTrustedName), fqdn \(validFQDN)")
		return validCertificate && validCommonNameEndsWithTrustedName && validFQDN
	} // checkSSL worker
	
	/// Check the fully qualified domain name (see https://en.wikipedia.org/wiki/Fully_qualified_domain_name)
	/// - Parameters:
	///   - serverCert: the certificate to check
	///   - expectedName: the expected domain name
	/// - Returns: True if they match
	private func checkFQDN(serverCert: Certificate, expectedName: String) -> Bool {
		
		return serverCert.commonName?.lowercased() == expectedName.lowercased()
	}
	
	/// Check the common name
	/// - Parameters:
	///   - commonName: the common name
	///   - trustedName: the trusted name
	/// - Returns: True if the common name is in the trusted names
	private func checkCommonName(_ commonName: String, trustedName: String?) -> Bool {
		
		guard let trustedName = trustedName else { return false }
		
		return commonName.lowercased().hasSuffix(trustedName.lowercased())
	}
	
	/// Check if the certificate matches any of the trusted cerfificates
	/// - Parameters:
	///   - serverCert: the certificate to check
	///   - trustedCertificates: the list of trusted certificates
	/// - Returns: True if the certificate is in the trusted list.
	private func checkCertificate(serverCert: Certificate, trustedCertificates: [Data]) -> Bool {
		
		for trustedCertificate in trustedCertificates where helper.compare(serverCert.data, with: trustedCertificate) {
			return true
		}
		return false
	}
} // SecurityCheckerWorker

/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Security

class SecurityCheckerWorker {
	
	internal func certificateFromPEM(certificateAsPemData: Data) -> SecCertificate? {
		
		let length = certificateAsPemData.count - 26
		let derb64 = certificateAsPemData.subdata(in: 28 ..< length)
		
		var str = String(decoding: derb64, as: UTF8.self)
		str = str.replacingOccurrences(of: "\n", with: "")
		
		// Fix if certificate has different line endings.
		if str.hasSuffix("\r-") {
			str = String(str.replacingOccurrences(of: "\r", with: "").dropLast())
		}
		
		if let data = Data(base64Encoded: str),
		   let cert = SecCertificateCreateWithData(nil, data as CFData) {
			return cert
		}
		return nil
	}
	
	// This function has an extra option, when the trustedCertificates are
	// empty, only used during testing.
	// if so - then the validation will also rely on anything in the system chain
	// (including any certs the user was fooled into adding, or added intentionally).
	//
	internal func checkATS(
		serverTrust: SecTrust,
		policies: [SecPolicy],
		trustedCertificates: [Data]) -> Bool {
			
			let trustList = createTrustList(trustedCertificates: trustedCertificates)
			
			if trustList.isEmpty {
				// add main chain back in.
				if errSecSuccess != SecTrustSetAnchorCertificatesOnly(serverTrust, false) {
					Current.logHandler.logError("checkATS: SecTrustSetAnchorCertificatesOnly failed)")
					return false
				}
			} else {
				// rely on just the anchors specified.
				let erm = SecTrustSetAnchorCertificates(serverTrust, trustList as CFArray)
				if errSecSuccess != erm {
					Current.logHandler.logError("checkATS: SecTrustSetAnchorCertificates failed: \(erm)")
					return false
				}
			}
			if errSecSuccess != SecTrustSetPolicies(serverTrust, policies as CFTypeRef) {
				Current.logHandler.logError("checkATS: SecTrustSetPolicies failed")
				return false
			}
			
			if #available(iOS 12.0, *) {
				return evaluateServerTrust(serverTrust)
			} else {
				// Fallback on earlier versions
				return evaluateServerTrustPreiOS12(serverTrust)
			}
		}
	
	private func createTrustList(trustedCertificates: [Data]) -> [SecCertificate] {
		
		var result: [SecCertificate] = []
		
		for certificateAsPemData in trustedCertificates {
			if let cert = certificateFromPEM(certificateAsPemData: certificateAsPemData) {
				result.append(cert)
				Current.logHandler.logVerbose("checkATS: adding cert \(cert.hashValue)")
			} else {
				Current.logHandler.logError("checkATS: Trust cert conversion failed")
			}
		}
		return result
	}
	
	@available(iOS 12.0, *)
	private func evaluateServerTrust(_ serverTrust: SecTrust) -> Bool {
		var error: CFError?
		let result = SecTrustEvaluateWithError(serverTrust, &error)
		if let error = error {
			Current.logHandler.logError("checkATS: SecTrustEvaluateWithError: \(error)")
		}
		return result
	}
	
	// Handle Server Trust pre iOS 12.
	private func evaluateServerTrustPreiOS12(_ serverTrust: SecTrust) -> Bool {
		
		var result = SecTrustResultType.invalid
		if errSecSuccess != SecTrustEvaluate(serverTrust, &result) {
			Current.logHandler.logError("checkATS: SecTrustEvaluate: \(result)")
			return false
		}
		switch result {
			case .unspecified:
				// We should be using SecTrustEvaluateWithError -- but cannot as that is > 12.0
				// so we have a weakness here - we cannot readily distinguish between the users chain
				// and our own lists. So that is a second stage comparison that we need to do.
				//
				Current.logHandler.logError("SecTrustEvaluate: unspecified - trusted by the OS or Us")
				return true
			case .proceed:
				Current.logHandler.logError("SecTrustEvaluate: proceed - trusted by the user; but not from our list.")
			case .deny:
				Current.logHandler.logError("SecTrustEvaluate: deny")
			case .invalid:
				Current.logHandler.logError("SecTrustEvaluate: invalid")
			case .recoverableTrustFailure:
				Current.logHandler.logDebug(SecTrustCopyResult(serverTrust).debugDescription)
				Current.logHandler.logError("SecTrustEvaluate: recoverableTrustFailure.")
			case .fatalTrustFailure:
				Current.logHandler.logError("SecTrustEvaluate: fatalTrustFailure")
			case .otherError:
				Current.logHandler.logError("SecTrustEvaluate: otherError")
			default:
				Current.logHandler.logError("SecTrustEvaluate: unknown")
		}
		Current.logHandler.logError("SecTrustEvaluate: returning false.")
		return false
	}
	
	private let openssl = OpenSSL()
	
	func checkSSL(
		serverTrust: SecTrust,
		policies: [SecPolicy],
		trustedCertificates: [Data],
		hostname: String,
		trustedName: String?) -> Bool {
			
		guard checkATS(
			serverTrust: serverTrust,
			policies: policies,
			trustedCertificates: trustedCertificates) else {
			Current.logHandler.logError("Bail on ATS")
				return false
			}
		
		guard trustedCertificates.isNotEmpty else {
			Current.logHandler.logVerbose("Skipping trustedCertificates check")
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
					Current.logHandler.logVerbose("Host Common Name: \(name)")
					validFQDN = validFQDN || checkFQDN(serverCert: serverCert, expectedName: hostname)
					validCommonNameEndsWithTrustedName = validCommonNameEndsWithTrustedName || checkCommonName(name, trustedName: trustedName)
				}
				if openssl.validateSubjectAlternativeDNSName(hostname, forCertificateData: serverCert.data) {
					validFQDN = true
					Current.logHandler.logVerbose("Host matched SAN \(hostname)")
				}
				validCertificate = validCertificate || checkCertificate(serverCert: serverCert, trustedCertificates: trustedCertificates)
			}
		}
		Current.logHandler.logVerbose("Server trust for \(hostname): validCert \(validCertificate), CN ending \(validCommonNameEndsWithTrustedName), fqdn \(validFQDN)")
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
		
		for trustedCertificate in trustedCertificates where openssl.compare(serverCert.data, withTrustedCertificate: trustedCertificate) {
			return true
		}
		return false
	}
} // SecurityCheckerWorker

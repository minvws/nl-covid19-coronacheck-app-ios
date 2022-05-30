/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Security

class SecurityCheckerWorker: Logging {
	
	internal func certificateFromPEM(certificateAsPemData: Data) -> SecCertificate? {
		
		let length = certificateAsPemData.count - 26
		let derb64 = certificateAsPemData.subdata(in: 28 ..< length)
		
		var str = String(decoding: derb64, as: UTF8.self)
		str = str.replacingOccurrences(of: "\n", with: "")
		
		// Fix if certificate has different line endings.
		if str.hasSuffix("\r-") {
			logVerbose("certificateAsPemData: \(String(decoding: certificateAsPemData, as: UTF8.self))")
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
					logError("checkATS: SecTrustSetAnchorCertificatesOnly failed)")
					return false
				}
			} else {
				// rely on just the anchors specified.
				let erm = SecTrustSetAnchorCertificates(serverTrust, trustList as CFArray)
				if errSecSuccess != erm {
					logError("checkATS: SecTrustSetAnchorCertificates failed: \(erm)")
					return false
				}
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
				logVerbose("checkATS: adding cert \(cert.hashValue)")
			} else {
				logError("checkATS: Trust cert conversion failed")
			}
		}
		return result
	}
	
	@available(iOS 12.0, *)
	private func evaluateServerTrust(_ serverTrust: SecTrust) -> Bool {
		var error: CFError?
		let result = SecTrustEvaluateWithError(serverTrust, &error)
		if let error = error {
			logError("checkATS: SecTrustEvaluateWithError: \(error)")
		}
		return result
	}
	
	// Handle Server Trust pre iOS 12.
	private func evaluateServerTrustPreiOS12(_ serverTrust: SecTrust) -> Bool {
		
		var result = SecTrustResultType.invalid
		if errSecSuccess != SecTrustEvaluate(serverTrust, &result) {
			logError("checkATS: SecTrustEvaluate: \(result)")
			return false
		}
		switch result {
			case .unspecified:
				// We should be using SecTrustEvaluateWithError -- but cannot as that is > 12.0
				// so we have a weakness here - we cannot readily distinguish between the users chain
				// and our own lists. So that is a second stage comparison that we need to do.
				//
				logError("SecTrustEvaluate: unspecified - trusted by the OS or Us")
				return true
			case .proceed:
				logError("SecTrustEvaluate: proceed - trusted by the user; but not from our list.")
			case .deny:
				logError("SecTrustEvaluate: deny")
			case .invalid:
				logError("SecTrustEvaluate: invalid")
			case .recoverableTrustFailure:
				logDebug(SecTrustCopyResult(serverTrust).debugDescription)
				logError("SecTrustEvaluate: recoverableTrustFailure.")
			case .fatalTrustFailure:
				logError("SecTrustEvaluate: fatalTrustFailure")
			case .otherError:
				logError("SecTrustEvaluate: otherError")
			default:
				logError("SecTrustEvaluate: unknown")
		}
		logError("SecTrustEvaluate: returning false.")
		return false
	}
	
	private let openssl = OpenSSL()
	
	func checkSSL(
		serverTrust: SecTrust,
		policies: [SecPolicy],
		trustedCertificates: [Data],
		hostname: String,
		trustedNames: [String]) -> Bool {
			
		guard checkATS(
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
			
		let hostnameLC = hostname.lowercased()
		var foundValidCertificate = false
		var foundValidCommonNameEndsWithTrustedName = trustedNames.isEmpty ? true : false
		var foundValidFullyQualifiedDomainName = false
		
		for index in 0 ..< SecTrustGetCertificateCount(serverTrust) {
			
			if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, index) {
				let serverCert = Certificate(certificate: serverCertificate)
				logVerbose("Server set at \(index) is \(serverCert)")
				
				if let name = serverCert.commonName {
					logVerbose("Hostname CN \(name)")
					if name.lowercased() == hostnameLC {
						foundValidFullyQualifiedDomainName = true
						logVerbose("Host matched CN \(name)")
					}
					if !foundValidCommonNameEndsWithTrustedName {
						for trustedName in trustedNames where name.lowercased().hasSuffix(trustedName.lowercased()) {
							foundValidCommonNameEndsWithTrustedName = true
							logVerbose("Found a valid name \(name)")
						}
					}
				}
				if openssl.validateSubjectAlternativeDNSName(hostnameLC, forCertificateData: serverCert.data) {
					foundValidFullyQualifiedDomainName = true
					logVerbose("Host matched SAN \(hostname)")
				}
				for trustedCertificate in trustedCertificates {
					if openssl.compare(serverCert.data, withTrustedCertificate: trustedCertificate) {
						logVerbose("Found a match with a trusted Certificate")
						foundValidCertificate = true
					}
				}
			}
		}
		logVerbose("Server trust for \(hostname): validCert \(foundValidCertificate), CN ending \(foundValidCommonNameEndsWithTrustedName), fqdn \(foundValidFullyQualifiedDomainName)")
		return foundValidCertificate && foundValidCommonNameEndsWithTrustedName && foundValidFullyQualifiedDomainName
	} // checkSSL worker
	
} // SecurityCheckerWorker

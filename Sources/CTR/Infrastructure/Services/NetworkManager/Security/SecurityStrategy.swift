/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Security

protocol CertificateProvider {
    
    func getHostNames() -> [String]
    
    func getSSLCertificate() -> Data?
    
    func getSigningCertificate() -> SigningCertificate?
}

/// The security strategy
enum SecurityStrategy {
    
    case none
    case config // 1.3
    case data // 1.4
    case provider(CertificateProvider) // 1.5
}

struct SecurityCheckerFactory {
    
    static func getSecurityChecker(
        _ strategy: SecurityStrategy,
        networkConfiguration: NetworkConfiguration,
        challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> SecurityCheckerProtocol {
        
        if case SecurityStrategy.none = strategy {
            return SecurityCheckerNone(
                challenge: challenge,
                completionHandler: completionHandler
            )
        }
        var trustedNames = [TrustConfiguration.commonNameContent]
        var trustedCertificates = [TrustConfiguration.sdNEVRootCA]
        var trustedSigners = [TrustConfiguration.sdNEVRootCACertificate]
        trustedSigners.append(TrustConfiguration.sdNRootCAG3Certificate)
        trustedSigners.append(TrustConfiguration.sdNPrivateRootCertificate)
        
        if networkConfiguration.name == "Development" || networkConfiguration.name == "Test" {
            trustedNames.append(TrustConfiguration.testNameContent)
            trustedCertificates.append(TrustConfiguration.rootISRGX1)
        }
        
        if case SecurityStrategy.data = strategy {
            trustedCertificates.append(TrustConfiguration.sdNRootCAG3)
            trustedCertificates.append(TrustConfiguration.sdNPrivateRoot)
        }
        
        if case let .provider(provider) = strategy {
            
            trustedNames.append(contentsOf: provider.getHostNames())
            if let signingCertificate = provider.getSigningCertificate() {
                trustedSigners.append(signingCertificate)
            }
            if let sslCertificate = provider.getSSLCertificate() {
                trustedCertificates.append(sslCertificate)
            }
            trustedCertificates.append(TrustConfiguration.sdNRootCAG3)
            trustedCertificates.append(TrustConfiguration.sdNPrivateRoot)
            //			trustedSigners.append(TrustConfiguration.sdNRootCAG3Certificate)
            //			trustedSigners.append(TrustConfiguration.sdNPrivateRootCertificate)
            if networkConfiguration.name != "Production" {
                trustedSigners.append(TrustConfiguration.zorgCspPrivateRootCertificate)
            }
            
            return SecurityCheckerProvider(
                trustedCertificates: trustedCertificates,
                trustedNames: trustedNames,
                trustedSigners: trustedSigners,
                challenge: challenge,
                completionHandler: completionHandler
            )
        }
        
        return SecurityChecker(
            trustedCertificates: trustedCertificates,
            trustedNames: trustedNames,
            trustedSigners: trustedSigners,
            challenge: challenge,
            completionHandler: completionHandler
        )
    }
}

protocol SecurityCheckerProtocol: SignatureValidating {
    
    /// Check the SSL Connection
    func checkSSL()
    
    /// Validate a PKCS7 signature
    /// - Parameters:
    ///   - signature: the signature to validate
    ///   - content: the signed content
    /// - Returns: True if the signature is a valid PKCS7 Signature
    func validate(signature: Data, content: Data) -> Bool
}

extension SecurityCheckerProtocol {
    
    /// Compare the Subject Alternative Name
    /// - Parameters:
    ///   - san: the subject alternative name
    ///   - name: the name to compare
    /// - Returns: True if the san matches
    func compareSan(_ san: String, name: String) -> Bool {
        
        let sanNames = san.split(separator: ",")
        for sanName in sanNames {
            // SanName can be like DNS: *.domain.nl
            let pattern = String(sanName)
                .replacingOccurrences(of: "DNS:", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if wildcardMatch(name, pattern: pattern) {
                return true
            }
        }
        return false
    }
    
    /// Wildcard matching
    /// - Parameters:
    ///   - string: the string to check
    ///   - pattern: the pattern to match
    /// - Returns: True if the string matches the pattern
    func wildcardMatch(_ string: String, pattern: String) -> Bool {
        
        let pred = NSPredicate(format: "self LIKE %@", pattern)
        return !NSArray(object: string).filtered(using: pred).isEmpty
    }
    
    /// Validate a PKCS7 Signature
    /// - Parameters:
    ///   - data: the signed content
    ///   - signature: the PKCS7 Signature
    ///   - completion: Completion handler
    func validate(data: Data, signature: Data, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            let result = validate(signature: signature, content: data)
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

/// Check nothing. Allow every connection. Used for testing.
class SecurityCheckerNone: SecurityChecker {
    
    /// Check the SSL Connection
    override func checkSSL() {
        
        completionHandler(.performDefaultHandling, nil)
    }
    
    /// Validate a PKCS7 signature
    /// - Parameters:
    ///   - signature: the signature to validate
    ///   - content: the signed content
    /// - Returns: True if the signature is a valid PKCS7 Signature
    override func validate(signature: Data, content: Data) -> Bool {
        
        return true
    }
}

class SecurityCheckerWorker: Logging {
    
    func certificateFromPEM(certificateAsPemData: Data) -> SecCertificate? {
        
        let lenght = certificateAsPemData.count - 26
        let derb64 = certificateAsPemData.subdata(in: 28 ..< lenght)
        
        var str = String(decoding: derb64, as: UTF8.self)
        str = str.replacingOccurrences(of: "\n", with: "")
        
        if let data = Data(base64Encoded: str) {
            if let cert = SecCertificateCreateWithData(nil, data as CFData) {
                return cert
            }
        }
        return nil
    }
    
    // This function has an extra option, when the trustedCertificates are
    // empty, only used during testing.
    // if so - then the validation will also rely on anything in the system chain
    // (including any certs the user was fooled into adding, or added intentionally).
    //
    func checkATS(serverTrust: SecTrust,
                  policies: [SecPolicy],
                  trustedCertificates: [Data]) -> Bool {
        var trustList: [SecCertificate] = []
        
        // XXX fixme -- use sensible covnersion; etc..
        for certificateAsPemData in trustedCertificates {
            if let cert = certificateFromPEM(certificateAsPemData: certificateAsPemData) {
                trustList.append(cert)
            }
        }
        if trustList.isEmpty {
            // add main chain back in.
            //
            if errSecSuccess != SecTrustSetAnchorCertificatesOnly(serverTrust, false) {
                logError("SecTrustSetAnchorCertificatesOnly failed)")
                return false
            }
        } else {
            // rely on just the achors specified.
            //
            let erm = SecTrustSetAnchorCertificates(serverTrust, trustList as CFArray)
            if errSecSuccess != erm {
                logError("SecTrustSetAnchorCertificates failed: \(erm)")
                return false
            }
        }

        var result = SecTrustResultType.invalid
        if errSecSuccess != SecTrustEvaluate(serverTrust, &result) {
            logError("SecTrustEvaluateWithError: \(result)")
            return false
        }
        switch result {
        case .unspecified:
            // We should be using SecTrustEvaluateWithError -- but cannot as that is > 12.0
            // so we have a weakness here - we cannot readily distingish between the users chain
            // and our own lists. So that is a second stage comparison that we need to do.
            //
            logError("SecTrustEvaluateWithError: unspecified - trusted by the OS or Us")
            return true
        case .proceed:
            logError("SecTrustEvaluateWithError: proceed - trusted by the user; but not from our list.")
        case .deny:
            logError("SecTrustEvaluateWithError: deny")
        case .invalid:
            logError("SecTrustEvaluateWithError: invalid")
        case .recoverableTrustFailure:
            logError("SecTrustEvaluateWithError: recoverableTrustFailure")
        case .fatalTrustFailure:
            logError("SecTrustEvaluateWithError: fatalTrustFailure")
        case .otherError:
            logError("SecTrustEvaluateWithError: otherError")
        default:
            logError("SecTrustEvaluateWithError: uknown")
        }
        logError("SecTrustEvaluateWithError: returning false.")
        return false
    } // checkATS()
    
    func checkSSL(serverTrust: SecTrust,
                  policies: [SecPolicy],
                  trustedCertificates: [Data],
                  hostname: String,
                  trustedNames: [String]
                  ) -> Bool {
        let openssl = OpenSSL()
        let hostnameLC = hostname.lowercased()

        if false == checkATS(serverTrust: serverTrust,
                             policies: policies,
                             trustedCertificates: trustedCertificates) {
            logVerbose("Bail on ATS")
            return false
        }
        
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        
        var foundValidCertificate = false
        var foundValidCommonNameEndsWithTrustedName = trustedNames.isEmpty ? true : false
        var foundValidFullyQualifiedDomainName = false
        
        for index in 0 ..< certificateCount {
            
            if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, index) {
                let serverCert = Certificate(certificate: serverCertificate)
                logDebug("Server set at \(index) is \(serverCert)")
                
                if let name = serverCert.commonName {
                    logVerbose("Hostname CN \(name)")
                    if name.lowercased() == hostnameLC {
                        foundValidFullyQualifiedDomainName = true
                        logDebug("Host matched CN \(name)")
                    }
                    if !foundValidCommonNameEndsWithTrustedName {
                        for trustedName in trustedNames {
                            if name.lowercased().hasSuffix(trustedName.lowercased()) {
                                foundValidCommonNameEndsWithTrustedName = true
                                logDebug("Found a valid name \(name)")
                            }
                        }
                    }
                }
                if openssl.validateSubjectAlternativeDNSName(hostnameLC, forCertificateData: serverCert.data) {
                    foundValidFullyQualifiedDomainName = true
                    logDebug("Host matched SAN \(hostname)")
                }
                for trustedCertificate in trustedCertificates {
                    if openssl.compare(serverCert.data, withTrustedCertificate: trustedCertificate) {
                        logDebug("Found a match with a trusted Certificate")
                        foundValidCertificate = true
                    }
                }
            }
        }
        if foundValidCertificate && foundValidCommonNameEndsWithTrustedName && foundValidFullyQualifiedDomainName {
            // all good
            logVerbose("Certificate signature is good for \(hostname)")
            return true
        };
        
        logError("Invalid server trust v=\(foundValidCertificate), cn=\(foundValidCommonNameEndsWithTrustedName) and fqdn=\(foundValidFullyQualifiedDomainName)")
        return false
    } // checkSSL worker
  
} // SecurityCheckerWorker

/// Security check for backend communication
class SecurityChecker: SecurityCheckerProtocol, Logging {
    
    var loggingCategory: String = "SecurityCheckerConfig"
    
    var trustedCertificates: [Data]
    var challenge: URLAuthenticationChallenge
    var completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    var trustedNames: [String]
    var trustedSigners: [SigningCertificate]
    var openssl = OpenSSL()
    
    init(
        trustedCertificates: [Data] = [],
        trustedNames: [String] = [],
        trustedSigners: [SigningCertificate] = [],
        challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        self.trustedCertificates = trustedCertificates
        self.trustedSigners = trustedSigners
        self.trustedNames = trustedNames
        self.challenge = challenge
        self.completionHandler = completionHandler
    }
    
    // Though ATS will validate this (too) - we force an early verification against a known list
    // ahead of time (defined here, no keychain) - also to trust the (relatively loose) comparisons
    // later (as we need to work with this data; which otherwise would be untrusted).
    //
    func checkATS(serverTrust: SecTrust) -> Bool {
        let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]
        
        return SecurityCheckerWorker().checkATS(serverTrust: serverTrust,
                                                policies: policies,
                                                trustedCertificates: trustedCertificates)
    }
    
    /// Check the SSL Connection
    func checkSSL() {
        
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            
            logDebug("No security strategy")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]

        if SecurityCheckerWorker().checkSSL(serverTrust: serverTrust,
                                                policies: policies,
                                                trustedCertificates: trustedCertificates,
                                                hostname: challenge.protectionSpace.host,
                                                trustedNames:trustedNames) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
        return
    }
    
    /// Validate a PKCS7 signature
    /// - Parameters:
    ///   - signature: the signature to validate
    ///   - content: the signed content
    /// - Returns: True if the signature is a valid PKCS7 Signature
    func validate(signature: Data, content: Data) -> Bool {
        
        for signer in trustedSigners {
            if openssl.validatePKCS7Signature(
                signature,
                contentData: content,
                certificateData: signer.getCertificateData()) {
                return true
            }
        }
        return false
    }
}

/// TestProvider security. Allows more certificates than allowed for backend stuff
class SecurityCheckerProvider: SecurityChecker {
    
    /// Check the SSL Connection
    override func checkSSL() {
        
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            logDebug("No policies/security strategy")
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let policies = [SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)]

        if SecurityCheckerWorker().checkSSL(serverTrust: serverTrust,
                                                policies: policies,
                                                trustedCertificates: trustedCertificates,
                                                hostname: challenge.protectionSpace.host,
                                                trustedNames: []) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
        return
    }
}

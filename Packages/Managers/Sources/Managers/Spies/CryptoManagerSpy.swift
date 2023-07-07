/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Mobilecore
import Models

public class CryptoManagerSpy: CryptoManaging {
	
	public init() {}

	public var invokedGenerateSecretKey = false
	public var invokedGenerateSecretKeyCount = 0
	public var stubbedGenerateSecretKeyResult: Data!

	public func generateSecretKey() -> Data? {
		invokedGenerateSecretKey = true
		invokedGenerateSecretKeyCount += 1
		return stubbedGenerateSecretKeyResult
	}

	public var invokedGenerateCommitmentMessage = false
	public var invokedGenerateCommitmentMessageCount = 0
	public var invokedGenerateCommitmentMessageParameters: (nonce: String, holderSecretKey: Data)?
	public var invokedGenerateCommitmentMessageParametersList = [(nonce: String, holderSecretKey: Data)]()
	public var stubbedGenerateCommitmentMessageResult: String!

	public func generateCommitmentMessage(nonce: String, holderSecretKey: Data) -> String? {
		invokedGenerateCommitmentMessage = true
		invokedGenerateCommitmentMessageCount += 1
		invokedGenerateCommitmentMessageParameters = (nonce, holderSecretKey)
		invokedGenerateCommitmentMessageParametersList.append((nonce, holderSecretKey))
		return stubbedGenerateCommitmentMessageResult
	}

	public var invokedHasPublicKeys = false
	public var invokedHasPublicKeysCount = 0
	public var stubbedHasPublicKeysResult: Bool! = false

	public func hasPublicKeys() -> Bool {
		invokedHasPublicKeys = true
		invokedHasPublicKeysCount += 1
		return stubbedHasPublicKeysResult
	}

	public var invokedIsForeignDCC = false
	public var invokedIsForeignDCCCount = 0
	public var invokedIsForeignDCCParameters: (data: Data, Void)?
	public var invokedIsForeignDCCParametersList = [(data: Data, Void)]()
	public var stubbedIsForeignDCCResult: Bool! = false

	public func isForeignDCC(_ data: Data) -> Bool {
		invokedIsForeignDCC = true
		invokedIsForeignDCCCount += 1
		invokedIsForeignDCCParameters = (data, ())
		invokedIsForeignDCCParametersList.append((data, ()))
		return stubbedIsForeignDCCResult
	}

	public var invokedIsDCC = false
	public var invokedIsDCCCount = 0
	public var invokedIsDCCParameters: (data: Data, Void)?
	public var invokedIsDCCParametersList = [(data: Data, Void)]()
	public var stubbedIsDCCResult: Bool! = false

	public func isDCC(_ data: Data) -> Bool {
		invokedIsDCC = true
		invokedIsDCCCount += 1
		invokedIsDCCParameters = (data, ())
		invokedIsDCCParametersList.append((data, ()))
		return stubbedIsDCCResult
	}

	public var invokedHasDomesticPrefix = false
	public var invokedHasDomesticPrefixCount = 0
	public var invokedHasDomesticPrefixParameters: (data: Data, Void)?
	public var invokedHasDomesticPrefixParametersList = [(data: Data, Void)]()
	public var stubbedHasDomesticPrefixResult: Bool! = false

	public func hasDomesticPrefix(_ data: Data) -> Bool {
		invokedHasDomesticPrefix = true
		invokedHasDomesticPrefixCount += 1
		invokedHasDomesticPrefixParameters = (data, ())
		invokedHasDomesticPrefixParametersList.append((data, ()))
		return stubbedHasDomesticPrefixResult
	}

	public var invokedReadEuCredentials = false
	public var invokedReadEuCredentialsCount = 0
	public var invokedReadEuCredentialsParameters: (data: Data, Void)?
	public var invokedReadEuCredentialsParametersList = [(data: Data, Void)]()
	public var stubbedReadEuCredentialsResult: EuCredentialAttributes!

	public func readEuCredentials(_ data: Data) -> EuCredentialAttributes? {
		invokedReadEuCredentials = true
		invokedReadEuCredentialsCount += 1
		invokedReadEuCredentialsParameters = (data, ())
		invokedReadEuCredentialsParametersList.append((data, ()))
		return stubbedReadEuCredentialsResult
	}

	public var invokedVerifyQRMessage = false
	public var invokedVerifyQRMessageCount = 0
	public var invokedVerifyQRMessageParameters: (message: String, Void)?
	public var invokedVerifyQRMessageParametersList = [(message: String, Void)]()
	public var stubbedVerifyQRMessageResult: Result<MobilecoreVerificationResult, CryptoError>!

	public func verifyQRMessage(_ message: String) -> Result<MobilecoreVerificationResult, CryptoError> {
		invokedVerifyQRMessage = true
		invokedVerifyQRMessageCount += 1
		invokedVerifyQRMessageParameters = (message, ())
		invokedVerifyQRMessageParametersList.append((message, ()))
		return stubbedVerifyQRMessageResult
	}
}

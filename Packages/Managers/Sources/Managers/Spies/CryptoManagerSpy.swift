/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore
import Models

class CryptoManagerSpy: CryptoManaging {

	var invokedGenerateSecretKey = false
	var invokedGenerateSecretKeyCount = 0
	var stubbedGenerateSecretKeyResult: Data!

	func generateSecretKey() -> Data? {
		invokedGenerateSecretKey = true
		invokedGenerateSecretKeyCount += 1
		return stubbedGenerateSecretKeyResult
	}

	var invokedGenerateCommitmentMessage = false
	var invokedGenerateCommitmentMessageCount = 0
	var invokedGenerateCommitmentMessageParameters: (nonce: String, holderSecretKey: Data)?
	var invokedGenerateCommitmentMessageParametersList = [(nonce: String, holderSecretKey: Data)]()
	var stubbedGenerateCommitmentMessageResult: String!

	func generateCommitmentMessage(nonce: String, holderSecretKey: Data) -> String? {
		invokedGenerateCommitmentMessage = true
		invokedGenerateCommitmentMessageCount += 1
		invokedGenerateCommitmentMessageParameters = (nonce, holderSecretKey)
		invokedGenerateCommitmentMessageParametersList.append((nonce, holderSecretKey))
		return stubbedGenerateCommitmentMessageResult
	}

	var invokedHasPublicKeys = false
	var invokedHasPublicKeysCount = 0
	var stubbedHasPublicKeysResult: Bool! = false

	func hasPublicKeys() -> Bool {
		invokedHasPublicKeys = true
		invokedHasPublicKeysCount += 1
		return stubbedHasPublicKeysResult
	}

	var invokedIsForeignDCC = false
	var invokedIsForeignDCCCount = 0
	var invokedIsForeignDCCParameters: (data: Data, Void)?
	var invokedIsForeignDCCParametersList = [(data: Data, Void)]()
	var stubbedIsForeignDCCResult: Bool! = false

	func isForeignDCC(_ data: Data) -> Bool {
		invokedIsForeignDCC = true
		invokedIsForeignDCCCount += 1
		invokedIsForeignDCCParameters = (data, ())
		invokedIsForeignDCCParametersList.append((data, ()))
		return stubbedIsForeignDCCResult
	}

	var invokedIsDCC = false
	var invokedIsDCCCount = 0
	var invokedIsDCCParameters: (data: Data, Void)?
	var invokedIsDCCParametersList = [(data: Data, Void)]()
	var stubbedIsDCCResult: Bool! = false

	func isDCC(_ data: Data) -> Bool {
		invokedIsDCC = true
		invokedIsDCCCount += 1
		invokedIsDCCParameters = (data, ())
		invokedIsDCCParametersList.append((data, ()))
		return stubbedIsDCCResult
	}

	var invokedHasDomesticPrefix = false
	var invokedHasDomesticPrefixCount = 0
	var invokedHasDomesticPrefixParameters: (data: Data, Void)?
	var invokedHasDomesticPrefixParametersList = [(data: Data, Void)]()
	var stubbedHasDomesticPrefixResult: Bool! = false

	func hasDomesticPrefix(_ data: Data) -> Bool {
		invokedHasDomesticPrefix = true
		invokedHasDomesticPrefixCount += 1
		invokedHasDomesticPrefixParameters = (data, ())
		invokedHasDomesticPrefixParametersList.append((data, ()))
		return stubbedHasDomesticPrefixResult
	}

	var invokedReadDomesticCredentials = false
	var invokedReadDomesticCredentialsCount = 0
	var invokedReadDomesticCredentialsParameters: (data: Data, Void)?
	var invokedReadDomesticCredentialsParametersList = [(data: Data, Void)]()
	var stubbedReadDomesticCredentialsResult: DomesticCredentialAttributes!

	func readDomesticCredentials(_ data: Data) -> DomesticCredentialAttributes? {
		invokedReadDomesticCredentials = true
		invokedReadDomesticCredentialsCount += 1
		invokedReadDomesticCredentialsParameters = (data, ())
		invokedReadDomesticCredentialsParametersList.append((data, ()))
		return stubbedReadDomesticCredentialsResult
	}

	var invokedReadEuCredentials = false
	var invokedReadEuCredentialsCount = 0
	var invokedReadEuCredentialsParameters: (data: Data, Void)?
	var invokedReadEuCredentialsParametersList = [(data: Data, Void)]()
	var stubbedReadEuCredentialsResult: EuCredentialAttributes!

	func readEuCredentials(_ data: Data) -> EuCredentialAttributes? {
		invokedReadEuCredentials = true
		invokedReadEuCredentialsCount += 1
		invokedReadEuCredentialsParameters = (data, ())
		invokedReadEuCredentialsParametersList.append((data, ()))
		return stubbedReadEuCredentialsResult
	}

	var invokedDiscloseCredential = false
	var invokedDiscloseCredentialCount = 0
	var invokedDiscloseCredentialParameters: (credential: Data, disclosurePolicy: DisclosurePolicy, holderSecretKey: Data)?
	var invokedDiscloseCredentialParametersList = [(credential: Data, disclosurePolicy: DisclosurePolicy, holderSecretKey: Data)]()
	var stubbedDiscloseCredentialResult: Data!

	func discloseCredential(_ credential: Data, forPolicy disclosurePolicy: DisclosurePolicy, withKey holderSecretKey: Data) -> Data? {
		invokedDiscloseCredential = true
		invokedDiscloseCredentialCount += 1
		invokedDiscloseCredentialParameters = (credential, disclosurePolicy, holderSecretKey)
		invokedDiscloseCredentialParametersList.append((credential, disclosurePolicy, holderSecretKey))
		return stubbedDiscloseCredentialResult
	}

	var invokedVerifyQRMessage = false
	var invokedVerifyQRMessageCount = 0
	var invokedVerifyQRMessageParameters: (message: String, Void)?
	var invokedVerifyQRMessageParametersList = [(message: String, Void)]()
	var stubbedVerifyQRMessageResult: Result<MobilecoreVerificationResult, CryptoError>!

	func verifyQRMessage(_ message: String) -> Result<MobilecoreVerificationResult, CryptoError> {
		invokedVerifyQRMessage = true
		invokedVerifyQRMessageCount += 1
		invokedVerifyQRMessageParameters = (message, ())
		invokedVerifyQRMessageParametersList.append((message, ()))
		return stubbedVerifyQRMessageResult
	}
}

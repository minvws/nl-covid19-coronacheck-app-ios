/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Clcore

class CryptoManagerSpy: CryptoManaging {

	var invokedSetNonce = false
	var invokedSetNonceCount = 0
	var invokedSetNonceParameters: (nonce: String, Void)?
	var invokedSetNonceParametersList = [(nonce: String, Void)]()

	func setNonce(_ nonce: String) {
		invokedSetNonce = true
		invokedSetNonceCount += 1
		invokedSetNonceParameters = (nonce, ())
		invokedSetNonceParametersList.append((nonce, ()))
	}

	var invokedSetStoken = false
	var invokedSetStokenCount = 0
	var invokedSetStokenParameters: (stoken: String, Void)?
	var invokedSetStokenParametersList = [(stoken: String, Void)]()

	func setStoken(_ stoken: String) {
		invokedSetStoken = true
		invokedSetStokenCount += 1
		invokedSetStokenParameters = (stoken, ())
		invokedSetStokenParametersList.append((stoken, ()))
	}

	var invokedGetStoken = false
	var invokedGetStokenCount = 0
	var stubbedGetStokenResult: String!

	func getStoken() -> String? {
		invokedGetStoken = true
		invokedGetStokenCount += 1
		return stubbedGetStokenResult
	}

	var invokedGenerateCommitmentMessage = false
	var invokedGenerateCommitmentMessageCount = 0
	var stubbedGenerateCommitmentMessageResult: String!

	func generateCommitmentMessage() -> String? {
		invokedGenerateCommitmentMessage = true
		invokedGenerateCommitmentMessageCount += 1
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

	var invokedCreateCredential = false
	var invokedCreateCredentialCount = 0
	var invokedCreateCredentialParameters: (ism: Data, Void)?
	var invokedCreateCredentialParametersList = [(ism: Data, Void)]()
	var stubbedCreateCredentialResult: Result<Data, CryptoError>!

	func createCredential(_ ism: Data) -> Result<Data, CryptoError> {
		invokedCreateCredential = true
		invokedCreateCredentialCount += 1
		invokedCreateCredentialParameters = (ism, ())
		invokedCreateCredentialParametersList.append((ism, ()))
		return stubbedCreateCredentialResult
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

	var invokedDiscloseCredential = false
	var invokedDiscloseCredentialCount = 0
	var invokedDiscloseCredentialParameters: (credential: Data, disclosurePolicy: DisclosurePolicy)?
	var invokedDiscloseCredentialParametersList = [(credential: Data, disclosurePolicy: DisclosurePolicy)]()
	var stubbedDiscloseCredentialResult: Data!

	func discloseCredential(_ credential: Data, disclosurePolicy: DisclosurePolicy) -> Data? {
		invokedDiscloseCredential = true
		invokedDiscloseCredentialCount += 1
		invokedDiscloseCredentialParameters = (credential, disclosurePolicy)
		invokedDiscloseCredentialParametersList.append((credential, disclosurePolicy))
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

	var invokedGenerateSecretKey = false
	var invokedGenerateSecretKeyCount = 0

	func generateSecretKey() {
		invokedGenerateSecretKey = true
		invokedGenerateSecretKeyCount += 1
	}
}

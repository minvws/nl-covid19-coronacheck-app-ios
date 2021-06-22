/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class CryptoManagerSpy: CryptoManaging {

	required init() {}

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

	var invokedSetIssuerDomesticPublicKeys = false
	var invokedSetIssuerDomesticPublicKeysCount = 0
	var invokedSetIssuerDomesticPublicKeysParameters: (keys: IssuerPublicKeys, Void)?
	var invokedSetIssuerDomesticPublicKeysParametersList = [(keys: IssuerPublicKeys, Void)]()
	var stubbedSetIssuerDomesticPublicKeysResult: Bool! = false

	func setIssuerDomesticPublicKeys(_ keys: IssuerPublicKeys) -> Bool {
		invokedSetIssuerDomesticPublicKeys = true
		invokedSetIssuerDomesticPublicKeysCount += 1
		invokedSetIssuerDomesticPublicKeysParameters = (keys, ())
		invokedSetIssuerDomesticPublicKeysParametersList.append((keys, ()))
		return stubbedSetIssuerDomesticPublicKeysResult
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

	var invokedReadCredential = false
	var invokedReadCredentialCount = 0
	var stubbedReadCredentialResult: CryptoAttributes!

	func readCredential() -> CryptoAttributes? {
		invokedReadCredential = true
		invokedReadCredentialCount += 1
		return stubbedReadCredentialResult
	}

	var invokedStoreCredential = false
	var invokedStoreCredentialCount = 0
	var invokedStoreCredentialParameters: (credential: Data, Void)?
	var invokedStoreCredentialParametersList = [(credential: Data, Void)]()

	func storeCredential(_ credential: Data) {
		invokedStoreCredential = true
		invokedStoreCredentialCount += 1
		invokedStoreCredentialParameters = (credential, ())
		invokedStoreCredentialParametersList.append((credential, ()))
	}

	var invokedRemoveCredential = false
	var invokedRemoveCredentialCount = 0

	func removeCredential() {
		invokedRemoveCredential = true
		invokedRemoveCredentialCount += 1
	}

	var invokedGenerateQRmessage = false
	var invokedGenerateQRmessageCount = 0
	var invokedGenerateQRmessageParameters: (credential: Data, Void)?
	var invokedGenerateQRmessageParametersList = [(credential: Data, Void)]()
	var stubbedGenerateQRmessageResult: Data!

	func generateQRmessage(_ credential: Data) -> Data? {
		invokedGenerateQRmessage = true
		invokedGenerateQRmessageCount += 1
		invokedGenerateQRmessageParameters = (credential, ())
		invokedGenerateQRmessageParametersList.append((credential, ()))
		return stubbedGenerateQRmessageResult
	}

	var invokedVerifyQRMessage = false
	var invokedVerifyQRMessageCount = 0
	var invokedVerifyQRMessageParameters: (message: String, Void)?
	var invokedVerifyQRMessageParametersList = [(message: String, Void)]()
	var stubbedVerifyQRMessageResult: CryptoResult!

	func verifyQRMessage(_ message: String) -> CryptoResult {
		invokedVerifyQRMessage = true
		invokedVerifyQRMessageCount += 1
		invokedVerifyQRMessageParameters = (message, ())
		invokedVerifyQRMessageParametersList.append((message, ()))
		return stubbedVerifyQRMessageResult
	}

	var invokedMigrateExistingCredential = false
	var invokedMigrateExistingCredentialCount = 0
	var invokedMigrateExistingCredentialParameters: (walletManager: WalletManaging, sampleDate: Date)?
	var invokedMigrateExistingCredentialParametersList = [(walletManager: WalletManaging, sampleDate: Date)]()

	func migrateExistingCredential(_ walletManager: WalletManaging, sampleDate: Date) {
		invokedMigrateExistingCredential = true
		invokedMigrateExistingCredentialCount += 1
		invokedMigrateExistingCredentialParameters = (walletManager, sampleDate)
		invokedMigrateExistingCredentialParametersList.append((walletManager, sampleDate))
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
}

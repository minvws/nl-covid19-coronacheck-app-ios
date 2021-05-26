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

	var invokedSetIssuerPublicKeys = false
	var invokedSetIssuerPublicKeysCount = 0
	var invokedSetIssuerPublicKeysParameters: (keys: [IssuerPublicKey], Void)?
	var invokedSetIssuerPublicKeysParametersList = [(keys: [IssuerPublicKey], Void)]()
	var stubbedSetIssuerPublicKeysResult: Bool! = false

	func setIssuerPublicKeys(_ keys: [IssuerPublicKey]) -> Bool {
		invokedSetIssuerPublicKeys = true
		invokedSetIssuerPublicKeysCount += 1
		invokedSetIssuerPublicKeysParameters = (keys, ())
		invokedSetIssuerPublicKeysParametersList.append((keys, ()))
		return stubbedSetIssuerPublicKeysResult
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
	var stubbedGenerateQRmessageResult: Data!

	func generateQRmessage() -> Data? {
		invokedGenerateQRmessage = true
		invokedGenerateQRmessageCount += 1
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
	var invokedMigrateExistingCredentialParameters: (walletManager: WalletManaging, Void)?
	var invokedMigrateExistingCredentialParametersList = [(walletManager: WalletManaging, Void)]()

	func migrateExistingCredential(_ walletManager: WalletManaging) {
		invokedMigrateExistingCredential = true
		invokedMigrateExistingCredentialCount += 1
		invokedMigrateExistingCredentialParameters = (walletManager, ())
		invokedMigrateExistingCredentialParametersList.append((walletManager, ()))
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
}

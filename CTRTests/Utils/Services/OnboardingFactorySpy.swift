/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class OnboardingFactorySpy: OnboardingFactoryProtocol {

	var invokedCreate = false
	var invokedCreateCount = 0
	var stubbedCreateResult: [PagedAnnoucementItem]! = []

	func create() -> [PagedAnnoucementItem] {
		invokedCreate = true
		invokedCreateCount += 1
		return stubbedCreateResult
	}

	var invokedGetConsentTitle = false
	var invokedGetConsentTitleCount = 0
	var stubbedGetConsentTitleResult: String! = ""

	func getConsentTitle() -> String {
		invokedGetConsentTitle = true
		invokedGetConsentTitleCount += 1
		return stubbedGetConsentTitleResult
	}

	var invokedGetConsentMessage = false
	var invokedGetConsentMessageCount = 0
	var stubbedGetConsentMessageResult: String! = ""

	func getConsentMessage() -> String {
		invokedGetConsentMessage = true
		invokedGetConsentMessageCount += 1
		return stubbedGetConsentMessageResult
	}

	var invokedGetConsentLink = false
	var invokedGetConsentLinkCount = 0
	var stubbedGetConsentLinkResult: String! = ""

	func getConsentLink() -> String {
		invokedGetConsentLink = true
		invokedGetConsentLinkCount += 1
		return stubbedGetConsentLinkResult
	}

	var invokedGetConsentButtonTitle = false
	var invokedGetConsentButtonTitleCount = 0
	var stubbedGetConsentButtonTitleResult: String! = ""

	func getConsentButtonTitle() -> String {
		invokedGetConsentButtonTitle = true
		invokedGetConsentButtonTitleCount += 1
		return stubbedGetConsentButtonTitleResult
	}

	var invokedGetConsentNotGivenError = false
	var invokedGetConsentNotGivenErrorCount = 0
	var stubbedGetConsentNotGivenErrorResult: String!

	func getConsentNotGivenError() -> String? {
		invokedGetConsentNotGivenError = true
		invokedGetConsentNotGivenErrorCount += 1
		return stubbedGetConsentNotGivenErrorResult
	}

	var invokedGetConsentItems = false
	var invokedGetConsentItemsCount = 0
	var stubbedGetConsentItemsResult: [String]! = []

	func getConsentItems() -> [String] {
		invokedGetConsentItems = true
		invokedGetConsentItemsCount += 1
		return stubbedGetConsentItemsResult
	}

	var invokedUseConsentButton = false
	var invokedUseConsentButtonCount = 0
	var stubbedUseConsentButtonResult: Bool! = false

	func useConsentButton() -> Bool {
		invokedUseConsentButton = true
		invokedUseConsentButtonCount += 1
		return stubbedUseConsentButtonResult
	}

	var invokedGetActionButtonTitle = false
	var invokedGetActionButtonTitleCount = 0
	var stubbedGetActionButtonTitleResult: String! = ""

	func getActionButtonTitle() -> String {
		invokedGetActionButtonTitle = true
		invokedGetActionButtonTitleCount += 1
		return stubbedGetActionButtonTitleResult
	}
}

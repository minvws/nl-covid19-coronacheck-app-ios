/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models

public class OnboardingFactorySpy: OnboardingFactoryProtocol {
	
	public init() {}

	public var invokedCreate = false
	public var invokedCreateCount = 0
	public var stubbedCreateResult: [PagedAnnoucementItem]! = []

	public func create() -> [PagedAnnoucementItem] {
		invokedCreate = true
		invokedCreateCount += 1
		return stubbedCreateResult
	}

	public var invokedGetConsentTitle = false
	public var invokedGetConsentTitleCount = 0
	public var stubbedGetConsentTitleResult: String! = ""

	public func getConsentTitle() -> String {
		invokedGetConsentTitle = true
		invokedGetConsentTitleCount += 1
		return stubbedGetConsentTitleResult
	}

	public var invokedGetConsentMessage = false
	public var invokedGetConsentMessageCount = 0
	public var stubbedGetConsentMessageResult: String! = ""

	public func getConsentMessage() -> String {
		invokedGetConsentMessage = true
		invokedGetConsentMessageCount += 1
		return stubbedGetConsentMessageResult
	}

	public var invokedGetConsentButtonTitle = false
	public var invokedGetConsentButtonTitleCount = 0
	public var stubbedGetConsentButtonTitleResult: String! = ""

	public func getConsentButtonTitle() -> String {
		invokedGetConsentButtonTitle = true
		invokedGetConsentButtonTitleCount += 1
		return stubbedGetConsentButtonTitleResult
	}

	public var invokedGetConsentNotGivenError = false
	public var invokedGetConsentNotGivenErrorCount = 0
	public var stubbedGetConsentNotGivenErrorResult: String!

	public func getConsentNotGivenError() -> String? {
		invokedGetConsentNotGivenError = true
		invokedGetConsentNotGivenErrorCount += 1
		return stubbedGetConsentNotGivenErrorResult
	}

	public var invokedGetConsentItems = false
	public var invokedGetConsentItemsCount = 0
	public var stubbedGetConsentItemsResult: [String]! = []

	public func getConsentItems() -> [String] {
		invokedGetConsentItems = true
		invokedGetConsentItemsCount += 1
		return stubbedGetConsentItemsResult
	}

	public var invokedUseConsentButton = false
	public var invokedUseConsentButtonCount = 0
	public var stubbedUseConsentButtonResult: Bool! = false

	public func useConsentButton() -> Bool {
		invokedUseConsentButton = true
		invokedUseConsentButtonCount += 1
		return stubbedUseConsentButtonResult
	}

	public var invokedGetActionButtonTitle = false
	public var invokedGetActionButtonTitleCount = 0
	public var stubbedGetActionButtonTitleResult: String! = ""

	public func getActionButtonTitle() -> String {
		invokedGetActionButtonTitle = true
		invokedGetActionButtonTitleCount += 1
		return stubbedGetActionButtonTitleResult
	}
}

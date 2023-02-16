/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
@testable import CTR
@testable import Managers
@testable import Models

class ScanInstructionsCoordinatorDelegateSpy: Coordinator, ScanInstructionsCoordinatorDelegate, OpenUrlProtocol {

	var invokedChildCoordinatorsSetter = false
	var invokedChildCoordinatorsSetterCount = 0
	var invokedChildCoordinators: [Coordinator]?
	var invokedChildCoordinatorsList = [[Coordinator]]()
	var invokedChildCoordinatorsGetter = false
	var invokedChildCoordinatorsGetterCount = 0
	var stubbedChildCoordinators: [Coordinator]! = []

	var childCoordinators: [Coordinator] {
		set {
			invokedChildCoordinatorsSetter = true
			invokedChildCoordinatorsSetterCount += 1
			invokedChildCoordinators = newValue
			invokedChildCoordinatorsList.append(newValue)
		}
		get {
			invokedChildCoordinatorsGetter = true
			invokedChildCoordinatorsGetterCount += 1
			return stubbedChildCoordinators
		}
	}

	var invokedNavigationControllerGetter = false
	var invokedNavigationControllerGetterCount = 0
	var stubbedNavigationController: UINavigationController!

	var navigationController: UINavigationController {
		invokedNavigationControllerGetter = true
		invokedNavigationControllerGetterCount += 1
		return stubbedNavigationController
	}

	var invokedStart = false
	var invokedStartCount = 0

	func start() {
		invokedStart = true
		invokedStartCount += 1
	}

	var invokedReceive = false
	var invokedReceiveCount = 0
	var invokedReceiveParameters: (universalLink: UniversalLink, Void)?
	var invokedReceiveParametersList = [(universalLink: UniversalLink, Void)]()
	var stubbedReceiveResult: Bool! = false

	func receive(universalLink: UniversalLink) -> Bool {
		invokedReceive = true
		invokedReceiveCount += 1
		invokedReceiveParameters = (universalLink, ())
		invokedReceiveParametersList.append((universalLink, ()))
		return stubbedReceiveResult
	}

	var invokedConsume = false
	var invokedConsumeCount = 0
	var invokedConsumeParameters: (universalLink: UniversalLink, Void)?
	var invokedConsumeParametersList = [(universalLink: UniversalLink, Void)]()
	var stubbedConsumeResult: Bool! = false

	func consume(universalLink: UniversalLink) -> Bool {
		invokedConsume = true
		invokedConsumeCount += 1
		invokedConsumeParameters = (universalLink, ())
		invokedConsumeParametersList.append((universalLink, ()))
		return stubbedConsumeResult
	}

	var invokedUserDidCompletePages = false
	var invokedUserDidCompletePagesCount = 0
	var invokedUserDidCompletePagesParameters: (hasScanLock: Bool, Void)?
	var invokedUserDidCompletePagesParametersList = [(hasScanLock: Bool, Void)]()

	func userDidCompletePages(hasScanLock: Bool) {
		invokedUserDidCompletePages = true
		invokedUserDidCompletePagesCount += 1
		invokedUserDidCompletePagesParameters = (hasScanLock, ())
		invokedUserDidCompletePagesParametersList.append((hasScanLock, ()))
	}

	var invokedUserDidCancelScanInstructions = false
	var invokedUserDidCancelScanInstructionsCount = 0

	func userDidCancelScanInstructions() {
		invokedUserDidCancelScanInstructions = true
		invokedUserDidCancelScanInstructionsCount += 1
	}

	var invokedUserWishesToSelectRiskSetting = false
	var invokedUserWishesToSelectRiskSettingCount = 0

	func userWishesToSelectRiskSetting() {
		invokedUserWishesToSelectRiskSetting = true
		invokedUserWishesToSelectRiskSettingCount += 1
	}

	var invokedUserWishesToReadPolicyInformation = false
	var invokedUserWishesToReadPolicyInformationCount = 0

	func userWishesToReadPolicyInformation() {
		invokedUserWishesToReadPolicyInformation = true
		invokedUserWishesToReadPolicyInformationCount += 1
	}

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, inApp: Bool)?
	var invokedOpenUrlParametersList = [(url: URL, inApp: Bool)]()

	func openUrl(_ url: URL, inApp: Bool) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, inApp)
		invokedOpenUrlParametersList.append((url, inApp))
	}
}

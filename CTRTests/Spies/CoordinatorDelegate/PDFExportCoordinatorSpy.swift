/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
import SnapshotTesting
@testable import CTR
import Shared
import Models

class PDFExportCoordinatorSpy: PDFExportCoordinator {

	var invokedChildCoordinatorsSetter = false
	var invokedChildCoordinatorsSetterCount = 0
	var invokedChildCoordinators: [Coordinator]?
	var invokedChildCoordinatorsList = [[Coordinator]]()
	var invokedChildCoordinatorsGetter = false
	var invokedChildCoordinatorsGetterCount = 0
	var stubbedChildCoordinators: [Coordinator]! = []

	override var childCoordinators: [Coordinator] {
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

	var invokedNavigationControllerSetter = false
	var invokedNavigationControllerSetterCount = 0
	var invokedNavigationController: UINavigationController?
	var invokedNavigationControllerList = [UINavigationController]()
	var invokedNavigationControllerGetter = false
	var invokedNavigationControllerGetterCount = 0
	var stubbedNavigationController: UINavigationController!

	override var navigationController: UINavigationController {
		set {
			invokedNavigationControllerSetter = true
			invokedNavigationControllerSetterCount += 1
			invokedNavigationController = newValue
			invokedNavigationControllerList.append(newValue)
		}
		get {
			invokedNavigationControllerGetter = true
			invokedNavigationControllerGetterCount += 1
			return stubbedNavigationController
		}
	}

	var invokedDelegateSetter = false
	var invokedDelegateSetterCount = 0
	var invokedDelegate: PDFExportFlowDelegate?
	var invokedDelegateList = [PDFExportFlowDelegate?]()
	var invokedDelegateGetter = false
	var invokedDelegateGetterCount = 0
	var stubbedDelegate: PDFExportFlowDelegate!

	override var delegate: PDFExportFlowDelegate? {
		set {
			invokedDelegateSetter = true
			invokedDelegateSetterCount += 1
			invokedDelegate = newValue
			invokedDelegateList.append(newValue)
		}
		get {
			invokedDelegateGetter = true
			invokedDelegateGetterCount += 1
			return stubbedDelegate
		}
	}

	var invokedStartPagesFactorySetter = false
	var invokedStartPagesFactorySetterCount = 0
	var invokedStartPagesFactory: StartPDFExportFactoryProtocol?
	var invokedStartPagesFactoryList = [StartPDFExportFactoryProtocol]()
	var invokedStartPagesFactoryGetter = false
	var invokedStartPagesFactoryGetterCount = 0
	var stubbedStartPagesFactory: StartPDFExportFactoryProtocol!

	override var startPagesFactory: StartPDFExportFactoryProtocol {
		set {
			invokedStartPagesFactorySetter = true
			invokedStartPagesFactorySetterCount += 1
			invokedStartPagesFactory = newValue
			invokedStartPagesFactoryList.append(newValue)
		}
		get {
			invokedStartPagesFactoryGetter = true
			invokedStartPagesFactoryGetterCount += 1
			return stubbedStartPagesFactory
		}
	}

	var invokedStart = false
	var invokedStartCount = 0

	override func start() {
		invokedStart = true
		invokedStartCount += 1
	}

	var invokedConsume = false
	var invokedConsumeCount = 0
	var invokedConsumeParameters: (universalLink: Models.UniversalLink, Void)?
	var invokedConsumeParametersList = [(universalLink: Models.UniversalLink, Void)]()
	var stubbedConsumeResult: Bool! = false

	override func consume(universalLink: Models.UniversalLink) -> Bool {
		invokedConsume = true
		invokedConsumeCount += 1
		invokedConsumeParameters = (universalLink, ())
		invokedConsumeParametersList.append((universalLink, ()))
		return stubbedConsumeResult
	}
}

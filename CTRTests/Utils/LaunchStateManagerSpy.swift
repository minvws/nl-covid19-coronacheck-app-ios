/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR

class LaunchStateManagerSpy: LaunchStateManaging {

	var invokedVersionSupplierSetter = false
	var invokedVersionSupplierSetterCount = 0
	var invokedVersionSupplier: AppVersionSupplierProtocol?
	var invokedVersionSupplierList = [AppVersionSupplierProtocol]()
	var invokedVersionSupplierGetter = false
	var invokedVersionSupplierGetterCount = 0
	var stubbedVersionSupplier: AppVersionSupplierProtocol!

	var versionSupplier: AppVersionSupplierProtocol {
		set {
			invokedVersionSupplierSetter = true
			invokedVersionSupplierSetterCount += 1
			invokedVersionSupplier = newValue
			invokedVersionSupplierList.append(newValue)
		}
		get {
			invokedVersionSupplierGetter = true
			invokedVersionSupplierGetterCount += 1
			return stubbedVersionSupplier
		}
	}

	var invokedDelegateSetter = false
	var invokedDelegateSetterCount = 0
	var invokedDelegate: LaunchStateManagerDelegate?
	var invokedDelegateList = [LaunchStateManagerDelegate?]()
	var invokedDelegateGetter = false
	var invokedDelegateGetterCount = 0
	var stubbedDelegate: LaunchStateManagerDelegate!

	var delegate: LaunchStateManagerDelegate? {
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

	var invokedHandleLaunchState = false
	var invokedHandleLaunchStateCount = 0
	var invokedHandleLaunchStateParameters: (state: LaunchState, Void)?
	var invokedHandleLaunchStateParametersList = [(state: LaunchState, Void)]()

	func handleLaunchState(_ state: LaunchState) {
		invokedHandleLaunchState = true
		invokedHandleLaunchStateCount += 1
		invokedHandleLaunchStateParameters = (state, ())
		invokedHandleLaunchStateParametersList.append((state, ()))
	}

	var invokedEnableRestart = false
	var invokedEnableRestartCount = 0

	func enableRestart() {
		invokedEnableRestart = true
		invokedEnableRestartCount += 1
	}
}

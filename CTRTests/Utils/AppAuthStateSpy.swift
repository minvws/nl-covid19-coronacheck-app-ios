/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import AppAuth
@testable import CTR

final class AppAuthStateSpy: AppAuthState {

	var invokedCurrentAuthorizationFlowSetter = false
	var invokedCurrentAuthorizationFlowSetterCount = 0
	var invokedCurrentAuthorizationFlow: OIDExternalUserAgentSession?
	var invokedCurrentAuthorizationFlowList = [OIDExternalUserAgentSession?]()
	var invokedCurrentAuthorizationFlowGetter = false
	var invokedCurrentAuthorizationFlowGetterCount = 0
	var stubbedCurrentAuthorizationFlow: OIDExternalUserAgentSession!

	var currentAuthorizationFlow: OIDExternalUserAgentSession? {
		set {
			invokedCurrentAuthorizationFlowSetter = true
			invokedCurrentAuthorizationFlowSetterCount += 1
			invokedCurrentAuthorizationFlow = newValue
			invokedCurrentAuthorizationFlowList.append(newValue)
		}
		get {
			invokedCurrentAuthorizationFlowGetter = true
			invokedCurrentAuthorizationFlowGetterCount += 1
			return stubbedCurrentAuthorizationFlow
		}
	}
}

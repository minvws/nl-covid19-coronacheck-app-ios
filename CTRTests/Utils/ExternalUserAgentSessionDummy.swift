/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import AppAuth

final class ExternalUserAgentSessionDummy: NSObject, OIDExternalUserAgentSession {
	
	func cancel() { }
	
	func cancel(completion: (() -> Void)? = nil) { }
	
	func resumeExternalUserAgentFlow(with URL: URL) -> Bool {
		return true
	}
	
	func failExternalUserAgentFlowWithError(_ error: Error) { }
}

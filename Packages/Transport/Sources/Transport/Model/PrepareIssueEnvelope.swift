/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct PrepareIssueEnvelope: Codable {
	
	public let prepareIssueMessage: String
	public let stoken: String

	public init(prepareIssueMessage: String, stoken: String) {
		self.prepareIssueMessage = prepareIssueMessage
		self.stoken = stoken
	}
}

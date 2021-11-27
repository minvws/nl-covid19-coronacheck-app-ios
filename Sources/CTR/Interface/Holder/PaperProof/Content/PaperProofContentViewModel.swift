/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class PaperProofContentViewModel: Logging {

	@Bindable private(set) var content: Content

	init(content: Content) {

		self.content = content
	}
}

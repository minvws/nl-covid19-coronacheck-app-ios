/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation

extension ScreenCaptureDetector {
	
	convenience init() {
		self.init(environmentIsProduction: Configuration().getRelease() == .production)
	}
}

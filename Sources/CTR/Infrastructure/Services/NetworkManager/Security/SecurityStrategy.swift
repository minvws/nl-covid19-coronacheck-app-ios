/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Security

/// The security strategy
enum SecurityStrategy {
	
	case none
	case config // 1.3
	case data // 1.4
	case provider(CertificateProvider) // 1.5
}

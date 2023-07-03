/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Nimble

public func eventuallyUnwrap<T>(eval: @escaping () -> T?) -> T? {
	
	var unwrapped: T?
	expect {
		guard let val = eval() else { return .failed(reason: "Could not unwrap") }
		unwrapped = val
		return .succeeded
	}.toEventually(succeed(), timeout: .seconds(2))
	
	return unwrapped
}

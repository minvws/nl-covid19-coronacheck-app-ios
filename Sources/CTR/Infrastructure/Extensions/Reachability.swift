/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Reachability

protocol ReachabilityProtocol: AnyObject {
	var whenReachable: ((Reachability) -> Void)? { get set }
//	var whenUnreachable: ((Reachability) -> Void)? { get set }

	func startNotifier() throws
}

extension Reachability: ReachabilityProtocol {}

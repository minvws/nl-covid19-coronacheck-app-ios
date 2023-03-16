/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

protocol MenuViewModelProtocol {
	
	typealias Item = MenuViewController.Item
	
	var title: Observable<String> { get }
	var items: Observable<[Item]> { get }
}

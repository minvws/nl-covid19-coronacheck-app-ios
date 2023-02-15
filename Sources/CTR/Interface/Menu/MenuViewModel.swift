/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit
import Shared
import Resources

class MenuViewModel {
	typealias Item = MenuViewController.Item
	
	@Bindable var title: String
	@Bindable var items: [Item]
	
	init(title: String = L.general_menu(), items: [Item]) {
		self.title = title
		self.items = items
	}
}

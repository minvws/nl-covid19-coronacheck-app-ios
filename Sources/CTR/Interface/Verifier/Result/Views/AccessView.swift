/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

typealias AccessView = UIView & AccessViewable

protocol AccessViewable: AnyObject {
	
	func title(_ title: String?)
	
	func primaryTitle(_ title: String?)
	
	func secondaryTitle(_ title: String?)
	
	func focusAccessibility()
}

extension AccessViewable {
	
	func primaryTitle(_ title: String?) { }
	
	func secondaryTitle(_ title: String?) { }
}

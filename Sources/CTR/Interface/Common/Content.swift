/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

// A common class for displaying content. Most of our pages consist of a title, a body/subTitle
// and a primary action (aka the big blue button at the bottom) + button title.
// This struct also has an optional second action + button title for more flexibility.
struct Content: Equatable {

	let title: String
	let subTitle: String?
	let primaryActionTitle: String?
	let primaryAction: (() -> Void)?
	let secondaryActionTitle: String?
	let secondaryAction: (() -> Void)?

	static func == (lhs: Content, rhs: Content) -> Bool {
		return lhs.title == rhs.title &&
			lhs.subTitle == rhs.subTitle &&
			lhs.primaryActionTitle == rhs.primaryActionTitle &&
			lhs.secondaryActionTitle == rhs.secondaryActionTitle
	}

	init(
		title: String,
		subTitle: String? = nil,
		primaryActionTitle: String? = nil,
		primaryAction: (() -> Void)? = nil,
		secondaryActionTitle: String? = nil,
		secondaryAction: (() -> Void)? = nil) {
			
		self.title = title
		self.subTitle = subTitle
		self.primaryActionTitle = primaryActionTitle
		self.primaryAction = primaryAction
		self.secondaryActionTitle = secondaryActionTitle
		self.secondaryAction = secondaryAction
	}
}

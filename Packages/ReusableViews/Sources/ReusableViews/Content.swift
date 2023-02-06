/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/*
 A common class for displaying content. Most of our pages consist of a title, a body/subTitle
 and a primary action (aka the big blue button at the bottom) + button title.
 This struct also has an optional second action + button title for more flexibility.
 */
public struct Content: Equatable {

	public let title: String
	public let body: String?
	public let primaryActionTitle: String?
	public let primaryAction: (() -> Void)?
	public let secondaryActionTitle: String?
	public let secondaryAction: (() -> Void)?

	public static func == (lhs: Content, rhs: Content) -> Bool {
		return lhs.title == rhs.title &&
			lhs.body == rhs.body &&
			lhs.primaryActionTitle == rhs.primaryActionTitle &&
			lhs.secondaryActionTitle == rhs.secondaryActionTitle
	}

	public init(
		title: String,
		body: String? = nil,
		primaryActionTitle: String? = nil,
		primaryAction: (() -> Void)? = nil,
		secondaryActionTitle: String? = nil,
		secondaryAction: (() -> Void)? = nil) {
			
		self.title = title
		self.body = body
		self.primaryActionTitle = primaryActionTitle
		self.primaryAction = primaryAction
		self.secondaryActionTitle = secondaryActionTitle
		self.secondaryAction = secondaryAction
	}
}

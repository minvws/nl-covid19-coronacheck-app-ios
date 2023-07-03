/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// A protocol for the notification center so it is mockable.
public protocol NotificationCenterProtocol {

	func addObserver(
		_ observer: Any,
		selector aSelector: Selector,
		name aName: NSNotification.Name?,
		object anObject: Any?
	)

	@discardableResult
	func addObserver(
		forName name: NSNotification.Name?,
		object obj: Any?,
		queue: OperationQueue?,
		using block: @escaping @Sendable (Notification) -> Void
	) -> NSObjectProtocol

	func removeObserver(_ observer: Any)
}

extension NotificationCenter: NotificationCenterProtocol {

	// Make NotificationCenter conform to NotificationCenterProtocol to allow mocking
}

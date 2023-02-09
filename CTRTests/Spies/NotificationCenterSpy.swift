/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR
import ReusableViews
import Shared

// If regenerating, watch out for `addObserver()` as it is customized to retain the `using block` parameter:

class NotificationCenterSpy: NotificationCenterProtocol {

	var invokedAddObserverSelector = false
	var invokedAddObserverSelectorCount = 0
	var invokedAddObserverSelectorParameters: (observer: Any, aSelector: Selector, aName: NSNotification.Name?, anObject: Any?)?
	var invokedAddObserverSelectorParametersList = [(observer: Any, aSelector: Selector, aName: NSNotification.Name?, anObject: Any?)]()

	func addObserver(
		_ observer: Any,
		selector aSelector: Selector,
		name aName: NSNotification.Name?,
		object anObject: Any?
	) {
		invokedAddObserverSelector = true
		invokedAddObserverSelectorCount += 1
		invokedAddObserverSelectorParameters = (observer, aSelector, aName, anObject)
		invokedAddObserverSelectorParametersList.append((observer, aSelector, aName, anObject))
	}

	var invokedAddObserverForName = false
	var invokedAddObserverForNameCount = 0
	var invokedAddObserverForNameParameters: (name: NSNotification.Name?, obj: Any?, queue: OperationQueue?, block: (Notification) -> Void)?
	var invokedAddObserverForNameParametersList = [(name: NSNotification.Name?, obj: Any?, queue: OperationQueue?, block: (Notification) -> Void)]()
	var stubbedAddObserverForNameBlockResult: (Notification, Void)?
	var stubbedAddObserverForNameResult: NSObjectProtocol!

	func addObserver(
		forName name: NSNotification.Name?,
		object obj: Any?,
		queue: OperationQueue?,
		using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
		invokedAddObserverForName = true
		invokedAddObserverForNameCount += 1
		invokedAddObserverForNameParameters = (name, obj, queue, block)
		invokedAddObserverForNameParametersList.append((name, obj, queue, block))
		if let result = stubbedAddObserverForNameBlockResult {
			block(result.0)
		}
		return stubbedAddObserverForNameResult
	}

	var invokedRemoveObserver = false
	var invokedRemoveObserverCount = 0
	var invokedRemoveObserverParameters: (observer: Any, Void)?
	var invokedRemoveObserverParametersList = [(observer: Any, Void)]()

	func removeObserver(_ observer: Any) {
		invokedRemoveObserver = true
		invokedRemoveObserverCount += 1
		invokedRemoveObserverParameters = (observer, ())
		invokedRemoveObserverParametersList.append((observer, ()))
	}
}

/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

// If regenerating, watch out for `addObserver()` as it is customized to retain the `using block` parameter:

public class NotificationCenterSpy: NotificationCenterProtocol {

	public init() {}
	
	public var invokedAddObserverSelector = false
	public var invokedAddObserverSelectorCount = 0
	public var invokedAddObserverSelectorParameters: (observer: Any, aSelector: Selector, aName: NSNotification.Name?, anObject: Any?)?
	public var invokedAddObserverSelectorParametersList = [(observer: Any, aSelector: Selector, aName: NSNotification.Name?, anObject: Any?)]()

	public func addObserver(
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

	public var invokedAddObserverForName = false
	public var invokedAddObserverForNameCount = 0
	public var invokedAddObserverForNameParameters: (name: NSNotification.Name?, obj: Any?, queue: OperationQueue?, block: (Notification) -> Void)?
	public var invokedAddObserverForNameParametersList = [(name: NSNotification.Name?, obj: Any?, queue: OperationQueue?, block: (Notification) -> Void)]()
	public var stubbedAddObserverForNameBlockResult: (Notification, Void)?
	public var stubbedAddObserverForNameResult: NSObjectProtocol!

	public func addObserver(
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

	public var invokedRemoveObserver = false
	public var invokedRemoveObserverCount = 0
	public var invokedRemoveObserverParameters: (observer: Any, Void)?
	public var invokedRemoveObserverParametersList = [(observer: Any, Void)]()

	public func removeObserver(_ observer: Any) {
		invokedRemoveObserver = true
		invokedRemoveObserverCount += 1
		invokedRemoveObserverParameters = (observer, ())
		invokedRemoveObserverParametersList.append((observer, ()))
	}
}

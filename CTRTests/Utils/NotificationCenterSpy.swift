/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

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
	var invokedAddObserverForNameParameters: (name: NSNotification.Name?, obj: Any?, queue: OperationQueue?)?
	var invokedAddObserverForNameParametersList = [(name: NSNotification.Name?, obj: Any?, queue: OperationQueue?)]()
	var stubbedAddObserverForNameBlockResult: (Notification, Void)?
	var stubbedAddObserverForNameResult: NSObjectProtocol!

	func addObserver(
		forName name: NSNotification.Name?,
		object obj: Any?,
		queue: OperationQueue?,
		using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
		invokedAddObserverForName = true
		invokedAddObserverForNameCount += 1
		invokedAddObserverForNameParameters = (name, obj, queue)
		invokedAddObserverForNameParametersList.append((name, obj, queue))
		if let result = stubbedAddObserverForNameBlockResult {
			block(result.0)
		}
		return stubbedAddObserverForNameResult
	}

	var invokedPost = false
	var invokedPostCount = 0
	var invokedPostParameters: (aName: NSNotification.Name, anObject: Any?)?
	var invokedPostParametersList = [(aName: NSNotification.Name, anObject: Any?)]()

	func post(name aName: NSNotification.Name, object anObject: Any?) {
		invokedPost = true
		invokedPostCount += 1
		invokedPostParameters = (aName, anObject)
		invokedPostParametersList.append((aName, anObject))
	}

	var invokedPostName = false
	var invokedPostNameCount = 0
	var invokedPostNameParameters: (aName: NSNotification.Name, anObject: Any?, aUserInfo: [AnyHashable: Any]?)?
	var invokedPostNameParametersList = [(aName: NSNotification.Name, anObject: Any?, aUserInfo: [AnyHashable: Any]?)]()

	func post(
		name aName: NSNotification.Name,
		object anObject: Any?,
		userInfo aUserInfo: [AnyHashable: Any]?
	) {
		invokedPostName = true
		invokedPostNameCount += 1
		invokedPostNameParameters = (aName, anObject, aUserInfo)
		invokedPostNameParametersList.append((aName, anObject, aUserInfo))
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

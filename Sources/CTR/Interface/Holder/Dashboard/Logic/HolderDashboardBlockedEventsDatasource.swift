/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

protocol HolderDashboardBlockedEventsDatasourceProtocol: AnyObject {
	var didUpdate: (([BlockedEventItem]) -> Void)? { get set }
}

class HolderDashboardBlockedEventsDatasource: NSObject, HolderDashboardBlockedEventsDatasourceProtocol {
 
	var didUpdate: (([BlockedEventItem]) -> Void)? {
		didSet {
			guard didUpdate != nil else { return }
			load()
		}
	}
	
	private let frc: NSFetchedResultsController<BlockedEvent>
	
	override init() {
		let fetchRequest = NSFetchRequest<BlockedEvent>(entityName: "BlockedEvent")
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \BlockedEvent.type, ascending: true)]
		
		frc = NSFetchedResultsController<BlockedEvent>(
			fetchRequest: fetchRequest,
			managedObjectContext: Current.dataStoreManager.managedObjectContext(),
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		
		super.init()
		
		frc.delegate = self
	}
	
	/// Is self-updating due to the FetchedResultsController. Performs first fetch when a `didUpdate` observer is registered.
	private func load() {
		guard didUpdate != nil else { return }
		try? frc.performFetch()
		notifyObserver()
	}
	
	private func notifyObserver() {
		guard let didUpdate = didUpdate else { return }
		
		let blockedEventItems = frc.fetchedObjects?.compactMap { blockedEvent -> BlockedEventItem? in
			guard let eventDate = blockedEvent.eventDate,
				  let reason = blockedEvent.reason,
				  let rawType = blockedEvent.type,
				  let originType = OriginType(rawValue: rawType)
			else { return nil }
			
			return BlockedEventItem(
				objectID: blockedEvent.objectID,
				eventDate: eventDate,
				reason: reason,
				type: originType
			)
		}
		
		didUpdate(blockedEventItems ?? [])
	}
}

extension HolderDashboardBlockedEventsDatasource: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		notifyObserver()
	}
}

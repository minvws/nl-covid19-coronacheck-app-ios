/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

// swiftlint:disable type_name
protocol HolderDashboardRemovedEventsDatasourceProtocol: AnyObject {
	var didUpdate: (([RemovedEventItem]) -> Void)? { get set }
}

class HolderDashboardRemovedEventsDatasource: NSObject, HolderDashboardRemovedEventsDatasourceProtocol {
 
	var didUpdate: (([RemovedEventItem]) -> Void)? {
		didSet {
			guard didUpdate != nil else { return }
			load()
		}
	}
	
	private let frc: NSFetchedResultsController<RemovedEvent>
	
	/// Initializer
	/// - Parameter reason: The reason of removed events. Currently RemovedEventModel.identityMismatch or RemovedEventModel.blockedEvent
	init(reason: RemovalReason) {
		let fetchRequest = NSFetchRequest<RemovedEvent>(entityName: RemovedEvent.entityName)
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \RemovedEvent.type, ascending: true)]
		fetchRequest.predicate = NSPredicate(format: "reason == %@", reason.rawValue)
		
		frc = NSFetchedResultsController<RemovedEvent>(
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
		
		let eventItems = frc.fetchedObjects?.compactMap { event -> RemovedEventItem? in
			guard let eventDate = event.eventDate,
				  let reason = event.reason,
				  let rawType = event.type,
				  let originType = OriginType(rawValue: rawType)
			else { return nil }
			
			return RemovedEventItem(
				objectID: event.objectID,
				eventDate: eventDate,
				reason: reason,
				type: originType
			)
		}
		
		didUpdate(eventItems ?? [])
	}
}

extension HolderDashboardRemovedEventsDatasource: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		notifyObserver()
	}
}

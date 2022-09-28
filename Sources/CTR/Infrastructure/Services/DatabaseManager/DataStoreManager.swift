/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData
import SQLite3

enum StorageType {
	case persistent, inMemory
}

extension Notification.Name {
	static let diskFull = Notification.Name("nl.rijksoverheid.ctr.diskFull")
}

protocol DataStoreManaging {

	/// Get a context to perform a query on
	/// - Returns: the main context
	func managedObjectContext() -> NSManagedObjectContext

	/// Save the context, saves all pending changes.
	/// - Parameter context: the context to be saved.
	func save(_ context: NSManagedObjectContext)
	
	func delete(_ objectID: NSManagedObjectID) -> Result<Void, Error>
}

class DataStoreManager: DataStoreManaging {

	enum Error: Swift.Error {
		case diskFull
		case underlying(error: Swift.Error)
	}

	private var storageType: StorageType
	private let flavor: AppFlavor

	/// The persistent container holding our data model
	private let persistentContainer: NSPersistentContainer

	/// Initialize the database manager
	/// - Parameter storageType: store the data in memory or on disk.
	required init(
		_ storageType: StorageType,
		flavor: AppFlavor = AppFlavor.flavor,
		loadPersistentStoreCompletion: @escaping (Result<DataStoreManager, DataStoreManager.Error>) -> Void
	) {
		self.storageType = storageType
		self.flavor = flavor
		
		let persistentContainer = NSPersistentContainer(name: flavor == .holder ? "CoronaCheck" : "Verifier")
		self.persistentContainer = persistentContainer
		
		let description = NSPersistentStoreDescription()
		description.shouldInferMappingModelAutomatically = true
		description.shouldMigrateStoreAutomatically = true
		description.isReadOnly = false
		description.setOption(
			FileProtectionType.complete as NSObject,
			forKey: NSPersistentStoreFileProtectionKey
		)
		if storageType == .inMemory {
			description.url = URL(fileURLWithPath: "/dev/null")
		} else {
			description.url = persistentContainer.persistentStoreDescriptions.last?.url
		}
		persistentContainer.persistentStoreDescriptions = [description]
		persistentContainer.loadPersistentStores(completionHandler: { storeDescription, error in
			
			if let error {
				// Catch an error indicating low disk-space:
				if DataStoreManager.isDiskFullError(error as NSError) {
					loadPersistentStoreCompletion(.failure(.diskFull))
				} else {
					loadPersistentStoreCompletion(.failure(.underlying(error: error)))
				}
			} else {
				loadPersistentStoreCompletion(.success(self))
			}

			if let url = storeDescription.url {
				self.excludeFromBackup(fileUrl: url)
			}
		})
		
		persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
	}
	
	/// Get a context to perform a query on
	/// - Returns: the main context
	func managedObjectContext() -> NSManagedObjectContext {

		return persistentContainer.viewContext
	}

	/// Save the context, saves all pending changes.
	/// - Parameter context: the context to be saved.
	func save(_ context: NSManagedObjectContext) {
		guard context.hasChanges else { return }
		
		do {
			try context.save()
		} catch let error as NSError {
			
			// Catch an error indicating low disk-space:
			if DataStoreManager.isDiskFullError(error) {
				NotificationCenter.default.post(name: .diskFull, object: nil)
			} else {
				fatalError("DatabaseController - saveContext error \(error), \(error.userInfo)")
			}
		}
		
		if persistentContainer.viewContext != context {
			persistentContainer.viewContext.refreshAllObjects()
		}
	}
	
	func delete(_ objectID: NSManagedObjectID) -> Result<Void, Swift.Error> {

		do {
			let eventGroup = try managedObjectContext().existingObject(with: objectID)
			managedObjectContext().delete(eventGroup)
			save(managedObjectContext())
			return .success(())
			
		} catch let error {
			return .failure(error)
		}
	}

	/// Exclude the database from backup
	/// - Parameter fileUrl: the url of the database
	private func excludeFromBackup(fileUrl: URL) {
		do {
			try FileManager.default.addSkipBackupAttributeToItemAt(fileUrl as NSURL)
		} catch {}
	}
	
	private static func isDiskFullError(_ error: NSError) -> Bool {
		if error.domain == NSSQLiteErrorDomain && error.code == SQLITE_FULL {
			return true
		}
		
		if let sqliteErrorCode = error.userInfo[NSSQLiteErrorDomain] as? NSNumber, sqliteErrorCode.int32Value == SQLITE_FULL {
			return true
		}
		
		return false
	}
}

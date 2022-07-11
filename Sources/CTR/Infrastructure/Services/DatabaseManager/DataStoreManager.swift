/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

enum StorageType {
	case persistent, inMemory
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

	private var storageType: StorageType
	// private let logHandler: Logging?

	private let flavor: AppFlavor

	/// The persistent container holding our data model
	private let persistentContainer: NSPersistentContainer

	/// Initialize the database manager
	/// - Parameter storageType: store the data in memory or on disk.
	required init(_ storageType: StorageType, flavor: AppFlavor = AppFlavor.flavor /*, logHandler: Logging? = nil*/, loadPersistentStoreCompletion: @escaping (Result<DataStoreManager, Error>) -> Void) {

		self.storageType = storageType
		self.flavor = flavor
		// self.logHandler = logHandler
		
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
			
			if let error = error {
				// self?.logHandler?.logError("DataStoreManager error \(error), \((error as NSError).userInfo)")
				loadPersistentStoreCompletion(.failure(error))
			} else {
				loadPersistentStoreCompletion(.success(self))
			}

			if let url = storeDescription.url {
				self.excludeFromBackup(fileUrl: url)
			}
		})
		
		persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
	}
	
	/// Exclude the database from backup
	/// - Parameter fileUrl: the url of the database
	private func excludeFromBackup(fileUrl: URL) {

		do {
			try FileManager.default.addSkipBackupAttributeToItemAt(fileUrl as NSURL)
		} catch {
			// logHandler?.logError("DatabaseController - Error excluding \(String(describing: fileUrl.lastPathComponent)) from backup")
		}
	}
	
	/// Get a context to perform a query on
	/// - Returns: the main context
	func managedObjectContext() -> NSManagedObjectContext {

		return persistentContainer.viewContext
	}

	/// Save the context, saves all pending changes.
	/// - Parameter context: the context to be saved.
	func save(_ context: NSManagedObjectContext) {

		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				// logHandler?.logError("DatabaseController - saveContext error \(nserror), \(nserror.userInfo)")
				fatalError("DatabaseController - saveContext error \(nserror), \(nserror.userInfo)")
			}

			if persistentContainer.viewContext != context {
				persistentContainer.viewContext.refreshAllObjects()
			}
		}
	}
	
	func delete(_ objectID: NSManagedObjectID) -> Result<Void, Error> {

		do {
			let eventGroup = try managedObjectContext().existingObject(with: objectID)
			managedObjectContext().delete(eventGroup)
			save(managedObjectContext())
			return .success(())
			
		} catch let error {
			return .failure(error)
		}
	}
}

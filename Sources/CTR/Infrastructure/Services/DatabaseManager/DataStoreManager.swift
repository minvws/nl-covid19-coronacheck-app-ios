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

	private var containerName: String {
		flavor == .holder ? "CoronaCheck" : "Verifier"
	}

	private var storageType: StorageType
	private let logHandler: Logging

	private let flavor: AppFlavor

	/// The persistent container holding our data model
	private lazy var persistentContainer: NSPersistentContainer = {

		let container = NSPersistentContainer(name: containerName)
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
			description.url = container.persistentStoreDescriptions.last?.url
		}
		container.persistentStoreDescriptions = [description]
		container.loadPersistentStores(completionHandler: { storeDescription, error in
			if let error = error as NSError? {
				self.logHandler.logError("DataStoreManager error \(error), \(error.userInfo)")
				fatalError("DataStoreManager error \(error), \(error.userInfo)")
			}
			if let url = storeDescription.url {
				self.excludeFromBackup(fileUrl: url)
			}
		})

		container.viewContext.automaticallyMergesChangesFromParent = true
		return container
	}()

	/// Exclude the database from backup
	/// - Parameter fileUrl: the url of the database
	private func excludeFromBackup(fileUrl: URL) {

		do {
			try FileManager.default.addSkipBackupAttributeToItemAt(fileUrl as NSURL)
		} catch {
			logHandler.logError("DatabaseController - Error excluding \(String(describing: fileUrl.lastPathComponent)) from backup")
		}
	}

	/// Initialize the database manager
	/// - Parameter storageType: store the data in memory or on disk.
	required init(_ storageType: StorageType, flavor: AppFlavor = AppFlavor.flavor, logHandler: Logging) {

		self.storageType = storageType
		self.flavor = flavor
		self.logHandler = logHandler
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
				logHandler.logError("DatabaseController - saveContext error \(nserror), \(nserror.userInfo)")
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

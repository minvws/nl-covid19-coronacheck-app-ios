/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

protocol DatabaseManaging {

	init()

	func managedObjectContext() -> NSManagedObjectContext

	func saveContext ()

	func clearCoreData()
}

class DatabaseManager: DatabaseManaging, Logging {

	private let containerName = "CoronaCheck"

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
		container.persistentStoreDescriptions = [description]
		container.loadPersistentStores(completionHandler: { storeDescription, error in
			if let error = error as NSError? {
				self.logError("DatabaseControllerUnresolved error \(error), \(error.userInfo)")
				fatalError("DatabaseControllerUnresolved error \(error), \(error.userInfo)")
			}
			if let url = storeDescription.url {
				self.excludeFromBackup(fileUrl: url)
			}
		})
		return container
	}()

	/// Exclude the database from backup
	/// - Parameter fileUrl: the url of the database
	private func excludeFromBackup(fileUrl: URL) {

		do {
			try FileManager.default.addSkipBackupAttributeToItemAt(fileUrl as NSURL)
		} catch {
			logError("DatabaseController - Error excluding \(String(describing: fileUrl.lastPathComponent)) from backup")
		}
	}

	required init() {
		// Required by protocol
	}

	/// Get a context to perform a query on
	/// - Returns: the main context
	func managedObjectContext() -> NSManagedObjectContext {

		return persistentContainer.viewContext
	}

	/// Save the context, saves all pending changes.
	func saveContext () {

		let context = managedObjectContext()
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				self.logError("DatabaseController - saveContext error \(nserror), \(nserror.userInfo)")
				fatalError("DatabaseController - saveContext error \(nserror), \(nserror.userInfo)")
			}
		}
	}

	/// Clear all the data, for all the stored entities.
	/// Used by unit test to clear the stack.
	func clearCoreData() {

		let context = managedObjectContext()
		context.performAndWait {
			for entity in self.persistentContainer.managedObjectModel.entities {

				guard let entityName = entity.name else {
					break
				}

				let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
				fetchRequest.includesSubentities = false
				do {
					for case let object as NSManagedObject in try context.fetch(fetchRequest) {
						context.delete(object)
					}
				} catch let error as NSError {
					self.logError("DatabaseController - clearCoreData deleteObject error : \(error)")
				}
			}
			self.saveContext()
		}
	}
}

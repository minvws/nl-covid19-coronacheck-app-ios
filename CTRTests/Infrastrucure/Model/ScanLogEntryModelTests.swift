/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
@testable import CTR
import CoreData

class ScanLogEntryModelTests: XCTestCase {
	
	var dataStoreManager: DataStoreManaging!
	
	override func setUp() {
		super.setUp()
		dataStoreManager = DataStoreManager(.inMemory, flavor: .verifier, logHandler: LogHandler())
	}

	// MARK: Tests

	func test_createEntry() {

		// Given
		var entry: ScanLogEntry?
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// When
			entry = ScanLogEntryModel.create(mode: "test_createEntry", date: date, managedContext: context)
		}

		// Then
		expect(entry).toEventuallyNot(beNil())
		expect(entry?.mode).toEventually(equal("test_createEntry"))
		expect(entry?.date).toEventually(equal(date))
	}

	func test_listFrom_noEntries() {

		// Given
		var listIsEmpty = false
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// When
			if let list = ScanLogEntryModel.listEntriesStartingFrom(date: date, managedContext: context).successValue {
				listIsEmpty = list.isEmpty
			}
		}
		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}

	func test_listTo_noEntries() {

		// Given
		var listIsEmpty = false
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			// When
			if let list = ScanLogEntryModel.listEntriesUpTo(date: date, managedContext: context).successValue {
				listIsEmpty = list.isEmpty
			}
		}
		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}

	func test_listFrom_oneEntries_outsideTimeInterval() {

		// Given
		var listIsEmpty = false
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			ScanLogEntryModel.create(mode: "1G", date: date.addingTimeInterval(ago * 5 * seconds), managedContext: context)

			// When
			if let list = ScanLogEntryModel.listEntriesStartingFrom(date: date, managedContext: context).successValue {
				listIsEmpty = list.isEmpty
			}
		}
		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}

	func test_listTo_oneEntries_outsideTimeInterval() {

		// Given
		var listIsEmpty = false
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			ScanLogEntryModel.create(mode: "1G", date: date, managedContext: context)

			// When
			if let list = ScanLogEntryModel.listEntriesUpTo(date: date.addingTimeInterval(ago * 5 * seconds), managedContext: context).successValue {
				listIsEmpty = list.isEmpty
			}
		}
		// Then
		expect(listIsEmpty).toEventually(beTrue())
	}

	func test_listFrom_oneEntry() {

		// Given
		var list = [ScanLogEntry]()
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			ScanLogEntryModel.create(mode: "test_list_oneEntry", date: date, managedContext: context)

			// When
			list = ScanLogEntryModel.listEntriesStartingFrom(date: date.addingTimeInterval(ago * 5 * seconds), managedContext: context).successValue ?? []
		}
		// Then
		expect(list).toEventuallyNot(beEmpty())
		expect(list).toEventually(haveCount(1))
		expect(list.first?.mode).toEventually(equal("test_list_oneEntry"))
	}

	func test_listTo_oneEntry() {

		// Given
		var list = [ScanLogEntry]()
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			ScanLogEntryModel.create(mode: "test_list_oneEntry", date: date.addingTimeInterval(ago * 5 * seconds), managedContext: context)

			// When
			list = ScanLogEntryModel.listEntriesUpTo(date: date, managedContext: context).successValue ?? []
		}
		// Then
		expect(list).toEventuallyNot(beEmpty())
		expect(list).toEventually(haveCount(1))
		expect(list.first?.mode).toEventually(equal("test_list_oneEntry"))
	}

	func test_listFrom_twoEntries() {

		// Given
		var list = [ScanLogEntry]()
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			ScanLogEntryModel.create(mode: "test_listFrom_twoEntries_first", date: date.addingTimeInterval(ago * 5 * seconds), managedContext: context)
			ScanLogEntryModel.create(mode: "test_listFrom_twoEntries_second", date: date, managedContext: context)

			// When
			list = ScanLogEntryModel.listEntriesStartingFrom(date: date.addingTimeInterval(ago * 5 * minute), managedContext: context).successValue ?? []
		}
		// Then
		expect(list).toEventuallyNot(beEmpty())
		expect(list).toEventually(haveCount(2))
	}

	func test_listTo_twoEntries() {

		// Given
		var list = [ScanLogEntry]()
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			ScanLogEntryModel.create(mode: "test_listTo_twoEntries_first", date: date.addingTimeInterval(ago * 10 * seconds), managedContext: context)
			ScanLogEntryModel.create(mode: "test_listTo_twoEntries_second", date: date.addingTimeInterval(ago * 5 * seconds), managedContext: context)

			// When
			list = ScanLogEntryModel.listEntriesUpTo(date: date, managedContext: context).successValue ?? []
		}
		// Then
		expect(list).toEventuallyNot(beEmpty())
		expect(list).toEventually(haveCount(2))
	}

	func test_listFrom_threeEntries() {

		// Given
		var list = [ScanLogEntry]()
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			ScanLogEntryModel.create(mode: "test_listFrom_threeEntries_first", date: date.addingTimeInterval(ago * 30 * seconds), managedContext: context)
			ScanLogEntryModel.create(mode: "test_listFrom_threeEntries_second", date: date.addingTimeInterval(ago * 20 * seconds), managedContext: context)
			ScanLogEntryModel.create(mode: "test_listFrom_threeEntries_third", date: date.addingTimeInterval(ago * 10 * seconds), managedContext: context)
			// When
			list = ScanLogEntryModel.listEntriesStartingFrom(date: date.addingTimeInterval(ago * 25 * seconds), managedContext: context).successValue ?? []
		}
		// Then
		expect(list).toEventuallyNot(beEmpty())
		expect(list).toEventually(haveCount(2))
	}

	func test_listTo_threeEntries() {

		// Given
		var list = [ScanLogEntry]()
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			ScanLogEntryModel.create(mode: "test_listTo_threeEntries_first", date: date.addingTimeInterval(ago * 30 * seconds), managedContext: context)
			ScanLogEntryModel.create(mode: "test_listTo_threeEntries_second", date: date.addingTimeInterval(ago * 20 * seconds), managedContext: context)
			ScanLogEntryModel.create(mode: "test_listTo_threeEntries_third", date: date.addingTimeInterval(ago * 10 * seconds), managedContext: context)
			// When
			list = ScanLogEntryModel.listEntriesUpTo(date: date.addingTimeInterval(ago * 15 * seconds), managedContext: context).successValue ?? []
		}
		// Then
		expect(list).toEventuallyNot(beEmpty())
		expect(list).toEventually(haveCount(2))
	}

	func test_listEntries() {

		// Given
		var list = [ScanLogEntry]()
		let date = Date()
		let context = dataStoreManager.managedObjectContext()
		context.performAndWait {

			ScanLogEntryModel.create(mode: "test_listEntries_first", date: date.addingTimeInterval(ago * 30 * seconds), managedContext: context)
			ScanLogEntryModel.create(mode: "test_listEntries_second", date: date.addingTimeInterval(ago * 20 * seconds), managedContext: context)
			ScanLogEntryModel.create(mode: "test_listEntries_third", date: date.addingTimeInterval(ago * 10 * seconds), managedContext: context)
			// When
			list = ScanLogEntryModel.listEntries(managedContext: context).successValue ?? []
		}
		// Then
		expect(list).toEventuallyNot(beEmpty())
		expect(list).toEventually(haveCount(3))
	}
}

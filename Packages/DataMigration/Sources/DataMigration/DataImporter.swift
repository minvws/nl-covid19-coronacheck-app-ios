/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

public class DataImporter {
	
	private var parcelCache = ThreadSafeCache<Int, MigrationParcel>()
	
	private var version: String
	
	private weak var delegate: DataImportDelegate?
	
	public init(version: String, delegate: DataImportDelegate?) {

		self.version = version
		self.delegate = delegate
	}
	
	public func importString(_ string: String) throws {

		if let decoded = Data(base64Encoded: string) {
			let decoder = JSONDecoder()
			let parcel = try decoder.decode(MigrationParcel.self, from: decoded)
			try importData(parcel)
		}
	}
	
	public func importData(_ parcel: MigrationParcel) throws {
		
		guard parcel.version == version else { throw DataMigrationError.invalidVersion }
		guard parcel.index < parcel.numberOfPackages else { throw DataMigrationError.invalidNumberOfPackages }

		if parcelCache[parcel.index] == nil {
			parcelCache[parcel.index] = parcel
			progress()
		}

		if parcelCache.values.count == parcel.numberOfPackages {
			logDebug("We got them all")
			let combinedData = try combine()
			delegate?.completed(combinedData)
		}
	}
	
	private func progress() {
		
		guard parcelCache.isNotEmpty else {
			delegate?.progress(0)
			return
		}
		
		let numberOfPackages = parcelCache.values.first?.value.numberOfPackages ?? 1
		let percentage = Float(parcelCache.values.count) / Float(numberOfPackages) * 100
		logVerbose("percent: \(percentage)")
		delegate?.progress(percentage)
	}
	
	private func combine() throws -> Data {
		
		let zipped = parcelCache.values
			.map { _, parcel in return parcel }
			.sorted { $0.index < $1.index }
			.reduce(Data()) { $0 + $1.payload }

		if zipped.isGzipped {
			do {
				let unzipped = try zipped.gunzipped()
				return unzipped
			} catch let error {
				logError(error.localizedDescription)
				throw error
			}
		} else {
			throw DataMigrationError.compressionError
		}
	}
}

public protocol DataImportDelegate: AnyObject {
	
	func completed(_ value: Data)
	
	func progress(_ percentage: Float)
}

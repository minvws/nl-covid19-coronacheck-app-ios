/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared

public protocol DataImportDelegate: AnyObject {
	
	func completed(_ value: Data)
	
	func progress(_ percentage: Float)
}

public protocol DataImportProtocol: AnyObject {
	
	var delegate: DataImportDelegate? { get set }
	
	func importString(_ string: String) throws
}

public class DataImporter: DataImportProtocol {
	
	private var parcelCache = ThreadSafeCache<Int, MigrationParcel>()
	
	private var version: String
	
	public weak var delegate: DataImportDelegate?

	public init(version: String) {

		self.version = version
	}
	
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
	
	private func importData(_ parcel: MigrationParcel) throws {
		
		guard parcel.version == version else { throw DataMigrationError.invalidVersion }
		guard parcel.index < parcel.numberOfPackages else { throw DataMigrationError.invalidNumberOfPackages }

		if parcelCache[parcel.index] == nil {
			parcelCache[parcel.index] = parcel
			progress()
		}

		if parcelCache.values.count == parcel.numberOfPackages {
			logDebug("DataImporter - We got them all")
			let combinedData = try unzip(stich(parcelCache.values))
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
		
	private func stich(_ values: [Int: MigrationParcel]) -> Data {
		
		return values
			.map { _, parcel in return parcel } // (Int, MigrationParcel) -> MigrationParcel
			.sorted { $0.index < $1.index } // In order
			.reduce(Data()) { $0 + $1.payload } // Combine MigrationParcel.payload
	}
	
	private func unzip(_ data: Data) throws -> Data {
		
		guard data.isGzipped else {
			throw DataMigrationError.compressionError
		}
		
		do {
			let unzipped = try data.gunzipped()
			return unzipped
		} catch let error {
			logError(error.localizedDescription)
			throw error
		}
	}
}

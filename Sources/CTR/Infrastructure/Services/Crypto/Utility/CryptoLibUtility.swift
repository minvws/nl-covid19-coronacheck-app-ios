/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

protocol CryptoLibUtilityProtocol: AnyObject {
	
	/// Returns true when public keys are saved
	var hasPublicKeys: Bool { get }
	
	/// Return true when core library is initialized
	var isInitialized: Bool { get }
	
	/// Initialize core library
	func initialize()
	
	/// Store data in documents directory
	/// - Parameters:
	///   - data: Data that needs to be saved
	///   - file: File type
	func store(_ data: Data, for file: CryptoLibUtility.File)

	/// Check if a file exists. If true, initialize
	/// - Parameter file: file type
	func checkFile(_ file: CryptoLibUtility.File)
}

final class CryptoLibUtility: CryptoLibUtilityProtocol, Logging {
	
	struct File: OptionSet {
		static let publicKeys = File(rawValue: 1 << 0)
		static let remoteConfiguration = File(rawValue: 1 << 1)
		static let all: File = [.publicKeys, .remoteConfiguration]
		static let empty: File = []
		
		let rawValue: Int
		
		var name: String {
			if self == File.publicKeys {
				return "public_keys.json"
			} else {
				return "config.json"
			}
		}
	}
	
	/// Returns true when public keys are saved
	var hasPublicKeys: Bool {
		return shouldInitialize.contains(.publicKeys)
	}
	
	/// Returns true when core library is initialized
	private(set) var isInitialized: Bool = false
	
	private var shouldInitialize: File {
		didSet {
			guard shouldInitialize.contains(.all) else {
				return
			}
			
			initialize()
		}
	}
	
	private let fileStorage: FileStorage
	private let flavor: AppFlavor
	
	init(fileStorage: FileStorage = FileStorage(), flavor: AppFlavor = AppFlavor.flavor) {
		self.fileStorage = fileStorage
		self.flavor = flavor
		self.shouldInitialize = .empty
	}
	
	/// Initialize core library
	func initialize() {
		
		let path = fileStorage.documentsURL?.path
		let result: MobilecoreResult?
		
		if flavor == .holder {
			// Initialize holder and have path to stored files as parameter
			result = MobilecoreInitializeHolder(path)
		} else {
			// Initialize verifier and have path to stored files as parameter
			result = MobilecoreInitializeVerifier(path)
		}
		
		if let result = result, !result.error.isEmpty {
			logError("Error initializing library: \(result.error)")
			isInitialized = false
		} else {
			logInfo("Initializing library successful")
			isInitialized = true
		}
	}
	
	/// Store data in documents directory
	/// - Parameters:
	///   - data: Data that needs to be saved
	///   - file: File type
	func store(_ data: Data, for file: CryptoLibUtility.File) {
		
		do {
			try fileStorage.store(data, as: file.name)
		} catch {
			logError("Failed to store \(file.name)")
			return
		}
		shouldInitialize.insert(file)
	}

	/// Check if a file exists. If true, initialize
	/// - Parameter file: file type
	func checkFile(_ file: CryptoLibUtility.File) {

		if fileStorage.fileExists(file.name) {
			shouldInitialize.insert(file)
		}
	}
}

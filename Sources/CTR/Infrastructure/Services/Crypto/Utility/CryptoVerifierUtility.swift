//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore

final class CryptoVerifierUtility: Logging {
	
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
	
	private var shouldInitialize: File {
		didSet {
			guard shouldInitialize.contains(.all) else {
				return
			}
			
			initialize()
			shouldInitialize = .empty
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
		
		guard flavor == .verifier else {
			return
		}
		
		// Initialize verifier and have path to stored files as parameter
		let path = fileStorage.documentsURL?.path
		let result = MobilecoreInitializeVerifier(path)
		
		if let result = result, !result.error.isEmpty {
			logError("Error initializing verifier: \(result.error)")
		} else {
			logInfo("Initializing verifier succeeded")
		}
	}
	
	/// Store data in documents directory
	/// - Parameters:
	///   - data: Data that needs to be saved
	///   - file: File type
	func store(_ data: Data, for file: File) {
		
		guard flavor == .verifier else {
			return
		}
		
		do {
			try fileStorage.store(data, as: file.name)
		} catch {
			logError("Failed to store \(file.name)")
			return
		}
		shouldInitialize.insert(file)
	}
}

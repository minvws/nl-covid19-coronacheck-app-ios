/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit
import Reachability
import Mobilecore
import Transport
import Shared
import Persistence
import Models

public protocol CryptoLibUtilityProtocol: AnyObject {
	
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
	
	func read(_ file: CryptoLibUtility.File) -> Data?

	/// Check if a file exists. If true, initialize
	/// - Parameter file: file type
	func checkFile(_ file: CryptoLibUtility.File)

	func update(
		isAppLaunching: Bool,
		immediateCallbackIfWithinTTL: (() -> Void)?,
		completion: ((Result<Bool, ServerError>) -> Void)?)

	/// Reset to default
	func wipePersistedData()
	
	func registerTriggers()
}

public final class CryptoLibUtility: CryptoLibUtilityProtocol {
	
	public struct File: OptionSet {
		public static let publicKeys = File(rawValue: 1 << 0)
		public static let remoteConfiguration = File(rawValue: 1 << 1)
		public static let all: File = [.publicKeys, .remoteConfiguration]
		public static let empty: File = []
		
		public let rawValue: Int
		
		public var name: String {
			if self == File.publicKeys {
				return "public_keys.json"
			} else {
				return "config.json"
			}
		}
		
		public init(rawValue: Int) {
			self.rawValue = rawValue
		}
	}

	// MARK: - Private vars

	private(set) var isLoading = false
	
	private var shouldInitialize: File {
		didSet {
			guard shouldInitialize.contains(.all) else {
				return
			}
			
			initialize()
		}
	}

	// MARK: - Dependencies

	private let fileStorage: FileStorageProtocol
	private let now: () -> Date
	private let userSettings: UserSettingsProtocol
	private let networkManager: NetworkManaging
	private let reachability: ReachabilityProtocol?
	private let remoteConfigManager: RemoteConfigManaging

	// MARK: - Setup

	public init(
		now: @escaping () -> Date,
		userSettings: UserSettingsProtocol,
		networkManager: NetworkManaging,
		remoteConfigManager: RemoteConfigManaging,
		reachability: ReachabilityProtocol?,
		fileStorage: FileStorageProtocol) {

		self.now = now
		self.networkManager = networkManager
		self.fileStorage = fileStorage
		self.userSettings = userSettings
		self.remoteConfigManager = remoteConfigManager
		self.shouldInitialize = .empty
		self.reachability = reachability
	}

	public func registerTriggers() {

		NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
			self?.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })
		}

		reachability?.whenReachable = { [weak self] _ in
			self?.update(isAppLaunching: false, immediateCallbackIfWithinTTL: {}, completion: { _ in })
		}
		try? reachability?.startNotifier()
	}

	// MARK: - Teardown

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - CryptoLibUtilityProtocol

	/// Returns true when public keys are saved
	public var hasPublicKeys: Bool {
		return shouldInitialize.contains(.publicKeys)
	}

	/// Returns true when core library is initialized
	public private(set) var isInitialized: Bool = false
	
	/// Initialize core library
	public func initialize() {
		
		let path = fileStorage.documentsURL?.path
		let result: MobilecoreResult?
		
		if AppFlavor.flavor == .holder {
			// Initialize holder and have path to stored files as parameter
			result = MobilecoreInitializeHolder(path)
		} else {
			// Initialize verifier and have path to stored files as parameter
			result = MobilecoreInitializeVerifier(path)
		}
		
		if let result, !result.error.isEmpty {
			logError("Error initializing library: \(result.error)")
			isInitialized = false
		} else {
			logVerbose("Initializing library successful")
			isInitialized = true
		}
	}
	
	/// Store data in documents directory
	/// - Parameters:
	///   - data: Data that needs to be saved
	///   - file: File type
	public func store(_ data: Data, for file: CryptoLibUtility.File) {
		
		do {
			try fileStorage.store(data, as: file.name)
		} catch {
			logError("Failed to store \(file.name)")
			return
		}
		shouldInitialize.insert(file)
	}
	
	public func read(_ file: CryptoLibUtility.File) -> Data? {
		return fileStorage.read(fileName: file.name)
	}

	/// Check if a file exists. If true, initialize
	/// - Parameter file: file type
	public func checkFile(_ file: CryptoLibUtility.File) {

		if fileStorage.fileExists(file.name) {
			shouldInitialize.insert(file)
		}
	}

	public func update(
		isAppLaunching: Bool,
		immediateCallbackIfWithinTTL: (() -> Void)?,
		completion: ((Result<Bool, ServerError>) -> Void)?) {

		guard !isLoading else { return }
		isLoading = true

		let newValidity = RemoteFileValidity.evaluateIfUpdateNeeded(
			configuration: remoteConfigManager.storedConfiguration,
			lastFetchedTimestamp: userSettings.issuerKeysFetchedTimestamp,
			isAppLaunching: isAppLaunching,
			now: now
		)

		// Special actions per-validity:
		switch newValidity {

			case .withinTTL:
				// If already within TTL, immediately trigger special callback
				// so that other app-startup work can begin:
				immediateCallbackIfWithinTTL?()

			default: break
		}

		guard newValidity != .withinMinimalInterval else {
			// Not allowed to call config endpoint again
			immediateCallbackIfWithinTTL?()
			completion?(.success(false))
			isLoading = false
			return
		}

		// Regardless, let's see if there's a new public key file available:
		networkManager.getPublicKeys { [weak self] (resultWrapper: Result<Data, ServerError>) in

			guard let self else { return }
			self.handleNetworkResponse(resultWrapper: resultWrapper, completion: completion)
			self.isLoading = false
		}
	}

	private func handleNetworkResponse(
		resultWrapper: Result<Data, ServerError>,
		completion: ((Result<Bool, ServerError>) -> Void)?
	) {
		switch resultWrapper {
			case let .failure(serverError):
				completion?(.failure(serverError))

			case let .success(data):

				// Update the last fetch-time
				userSettings.issuerKeysFetchedTimestamp = now().timeIntervalSince1970
				store(data, for: .publicKeys)
				completion?(.success(true))
		}
	}

	/// Reset to default
	public func wipePersistedData() {

		// Remove existing files
		if fileStorage.fileExists(CryptoLibUtility.File.publicKeys.name) {
			fileStorage.remove(CryptoLibUtility.File.publicKeys.name)
			userSettings.issuerKeysFetchedTimestamp = nil
		}
		if fileStorage.fileExists(CryptoLibUtility.File.remoteConfiguration.name) {
			fileStorage.remove(CryptoLibUtility.File.remoteConfiguration.name)
			userSettings.configFetchedTimestamp = nil
		}
	}
}

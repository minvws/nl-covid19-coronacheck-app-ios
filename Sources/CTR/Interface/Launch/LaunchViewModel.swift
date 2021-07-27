/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LaunchViewModel: Logging {

	private weak var coordinator: AppCoordinatorDelegate?

	private var versionSupplier: AppVersionSupplierProtocol?
	private var remoteConfigManager: RemoteConfigManaging?
	private weak var walletManager: WalletManaging?
	private var proofManager: ProofManaging
	private weak var jailBreakDetector: JailBreakProtocol?
	private weak var userSettings: UserSettingsProtocol?
	private let cryptoLibUtility: CryptoLibUtilityProtocol

	private var isUpdatingConfiguration = false
	private var isUpdatingIssuerPublicKeys = false

	private var flavor: AppFlavor

	private let dependencyGroup = DispatchGroup()

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var version: String
	@Bindable private(set) var appIcon: UIImage?
	@Bindable private(set) var interruptForJailBreakDialog: Bool = false

	@UserDefaults(key: "lastFetchedTimestamp", defaultValue: nil)
	var lastFetchedTimestamp: Date? // swiftlint:disable:this let_var_whitespace

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - versionSupplier: the version supplier
	///   - flavor: the app flavor (holder or verifier)
	///   - remoteConfigManager: the manager for fetching the remote configuration
	///   - proofManager: the proof manager for fetching the keys
	///   - jailBreakDetector: the detector for detecting jailbreaks
	///   - userSettings: the settings used for storing if the user has seen the jail break warning (if device is jailbroken)
	///   - cryptoLibUtility: the crypto library utility
	init(
		coordinator: AppCoordinatorDelegate,
		versionSupplier: AppVersionSupplierProtocol?,
		flavor: AppFlavor,
		remoteConfigManager: RemoteConfigManaging? = Services.remoteConfigManager,
		proofManager: ProofManaging = Services.proofManager,
		jailBreakDetector: JailBreakProtocol? = JailBreakDetector(),
		userSettings: UserSettingsProtocol? = UserSettings(),
		cryptoLibUtility: CryptoLibUtilityProtocol = Services.cryptoLibUtility,
		walletManager: WalletManaging?) {

		self.coordinator = coordinator
		self.versionSupplier = versionSupplier
		self.remoteConfigManager = remoteConfigManager
		self.proofManager = proofManager
		self.flavor = flavor
		self.jailBreakDetector = jailBreakDetector
		self.userSettings = userSettings
		self.cryptoLibUtility = cryptoLibUtility
		self.walletManager = walletManager

		title = flavor == .holder ? L.holderLaunchTitle() : L.verifierLaunchTitle()
		message = flavor == .holder  ? L.holderLaunchText() : L.verifierLaunchText()
		appIcon = flavor == .holder ? .holderAppIcon : .verifierAppIcon

		version = flavor == .holder
			? L.holderLaunchVersion(versionSupplier?.getCurrentVersion() ?? "", versionSupplier?.getCurrentBuild() ?? "")
			: L.verifierLaunchVersion(versionSupplier?.getCurrentVersion() ?? "", versionSupplier?.getCurrentBuild() ?? "")

		if shouldShowJailBreakAlert() {
			// Interrupt, do not continu the flow
			interruptForJailBreakDialog = true
		} else {
			// Continu with the flow
			interruptForJailBreakDialog = false
			updateDependencies()
		}
	}

	/// Update the dependencies
	private func updateDependencies() {

		// Configuration
		var configStatus: LaunchState?
		dependencyGroup.enter()
		updateConfiguration { result in

			configStatus = result
			self.dependencyGroup.leave()
		}

		// Issuer Public Keys
		var issuerPublicKeysStatus: LaunchState?
		dependencyGroup.enter()
		updateKeys { result in

			issuerPublicKeysStatus = result
			self.dependencyGroup.leave()
		}

		dependencyGroup.notify(queue: DispatchQueue.main) {

			if self.flavor == .holder {
				self.checkWallet()
			}

			if case let .actionRequired(info) = configStatus {
				// show action
				self.coordinator?.handleLaunchState(.actionRequired(info))
			} else if configStatus == .internetRequired || issuerPublicKeysStatus == .internetRequired {
				// Show no internet
				self.coordinator?.handleLaunchState(.internetRequired)
			} else if !self.cryptoLibUtility.isInitialized {
				// Show crypto lib not initialized error
				self.coordinator?.handleLaunchState(.cryptoLibNotInitialized)
			} else {
				// Start application
				self.coordinator?.handleLaunchState(.noActionNeeded)
			}
		}
	}

	private func shouldShowJailBreakAlert() -> Bool {

		guard flavor == .holder else {
			// Only enable for the holder
			return false
		}

		guard let jailBreakDetector = jailBreakDetector, let userSettings = userSettings else {
			return false
		}

		return !userSettings.jailbreakWarningShown && jailBreakDetector.isJailBroken()
	}

	func userDismissedJailBreakWarning() {

		// Interruption is over
		interruptForJailBreakDialog = false
		// Warning has been shown, do not show twice
		userSettings?.jailbreakWarningShown = true
		// Continu with flow
		updateDependencies()
	}

	/// Update the configuration
	private func updateConfiguration(_ completion: @escaping (LaunchState) -> Void) {

		// Execute once.
		guard !isUpdatingConfiguration else {
			return
		}

		isUpdatingConfiguration = true
		remoteConfigManager?.update { resultWrapper in

			self.isUpdatingConfiguration = false

			switch resultWrapper {
				case .success((let remoteConfiguration, let data)):

					// Update the last fetch time
					self.lastFetchedTimestamp = Date()
					// Store as JSON file
					self.cryptoLibUtility.store(data, for: .remoteConfiguration)
					// Decide what to do
					self.compare(remoteConfiguration, completion: completion)

				case let .failure(networkError):

					self.logError("Error retreiving remote configuration: \(networkError.localizedDescription)")

					// Fallback to the last known remote configuration
					guard let storedConfiguration = self.remoteConfigManager?.getConfiguration() else {
						completion(.internetRequired)
						return
					}

					self.logDebug("Using stored Configuration \(storedConfiguration)")
					//
					if let lastFetchedTimestamp = self.lastFetchedTimestamp,
					   lastFetchedTimestamp > Date() - TimeInterval(storedConfiguration.configTTL ?? 0) {
						// We still got a remote configuration within the config TTL.
						self.logInfo("Remote Configuration still within TTL")
						self.compare(storedConfiguration, completion: completion)
					} else {
						self.compare(storedConfiguration) { state in
							switch state {
								case .actionRequired:
									// Deactiviated or update trumps no internet
									completion(state)
								default:
									completion(.internetRequired)
							}
						}
					}
			}
		}
	}

	/// Compare the remote configuration against the app version
	/// - Parameters:
	///   - remoteConfiguration: the remote configuration
	///   - completion: completion handler
	private func compare(
		_ remoteConfiguration: RemoteInformation,
		completion: @escaping (LaunchState) -> Void) {

		let requiredVersion = fullVersionString(remoteConfiguration.minimumVersion)
		let currentVersion = fullVersionString(versionSupplier?.getCurrentVersion() ?? "1.0.0")

		if requiredVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
			// Update the app
			completion(.actionRequired(remoteConfiguration))
		} else if remoteConfiguration.isDeactivated {
			// Kill the app
			completion(.actionRequired(remoteConfiguration))
		} else {
			// Nothing to do
			completion(.noActionNeeded)
		}
	}

	/// Get a three digit string of the version
	/// - Parameter version: the version
	/// - Returns: three digit string of the version
	private func fullVersionString(_ version: String) -> String {

		var components = version.split(separator: ".")
		let missingComponents = max(0, 3 - components.count)
		components.append(contentsOf: Array(repeating: "0", count: missingComponents))
		return components.joined(separator: ".")
	}

	private func checkWallet() {

		guard let configuration = remoteConfigManager?.getConfiguration() else {
			return
		}

		walletManager?.expireEventGroups(
			vaccinationValidity: configuration.vaccinationEventValidity,
			recoveryValidity: configuration.recoveryEventValidity,
			testValidity: configuration.testEventValidity
		)
	}

	private func updateKeys(_ completion: @escaping (LaunchState) -> Void) {

		// Execute once.
		guard !isUpdatingIssuerPublicKeys else {
			return
		}

		isUpdatingIssuerPublicKeys = true
		proofManager.fetchIssuerPublicKeys { [weak self] in

			self?.isUpdatingIssuerPublicKeys = false
			completion(.noActionNeeded)

		} onError: { [weak self] error in

			self?.isUpdatingIssuerPublicKeys = false
			completion(.internetRequired)
		}
	}
}

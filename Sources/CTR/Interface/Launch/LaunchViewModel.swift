/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import LocalAuthentication

class LaunchViewModel: Logging {

	private weak var coordinator: AppCoordinatorDelegate?

	private var versionSupplier: AppVersionSupplierProtocol?
	private weak var remoteConfigManager: RemoteConfigManaging? = Services.remoteConfigManager
	private weak var walletManager: WalletManaging?
	private weak var proofManager: ProofManaging? = Services.proofManager
	private weak var jailBreakDetector: JailBreakProtocol? = Services.jailBreakDetector
	private weak var deviceAuthenticationDetector: DeviceAuthenticationProtocol? = Services.deviceAuthenticationDetector
	private var userSettings: UserSettingsProtocol?
	private weak var cryptoLibUtility: CryptoLibUtilityProtocol? = Services.cryptoLibUtility

	private var isUpdatingConfiguration = false
	private var isUpdatingIssuerPublicKeys = false

	private var flavor: AppFlavor
	var configStatus: LaunchState?
	var issuerPublicKeysStatus: LaunchState?
	var didFinishLaunchState = false

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var version: String
	@Bindable private(set) var appIcon: UIImage?
	@Bindable private(set) var alert: AlertContent?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - versionSupplier: the version supplier
	///   - flavor: the app flavor (holder or verifier)
	///   - userSettings: the settings used for storing if the user has seen the jail break warning (if device is jailbroken)
	init(
		coordinator: AppCoordinatorDelegate,
		versionSupplier: AppVersionSupplierProtocol?,
		flavor: AppFlavor,
		userSettings: UserSettingsProtocol? = UserSettings()) {

		self.coordinator = coordinator
		self.versionSupplier = versionSupplier
		self.flavor = flavor
		self.userSettings = userSettings

		title = flavor == .holder ? L.holderLaunchTitle() : L.verifierLaunchTitle()
		message = flavor == .holder  ? L.holderLaunchText() : L.verifierLaunchText()
		appIcon = flavor == .holder ? I.holderAppIcon() : I.verifierAppIcon()

		version = flavor == .holder
			? L.holderLaunchVersion(versionSupplier?.getCurrentVersion() ?? "", versionSupplier?.getCurrentBuild() ?? "")
			: L.verifierLaunchVersion(versionSupplier?.getCurrentVersion() ?? "", versionSupplier?.getCurrentBuild() ?? "")

		walletManager = flavor == .holder ? Services.walletManager : nil

		startChecks()
	}

	private func startChecks() {

		if shouldShowJailBreakAlert() {
			showJailBreakAlert()
		} else if shouldShowDeviceAuthenticationAlert() {
			showDeviceAuthenticationAlert()
		} else {
			updateDependencies()
		}
	}

	/// Update the dependencies
	private func updateDependencies() {

		// Configuration
		updateConfiguration { result in
			self.configStatus = result
			self.handleState()
		}

		// Issuer Public Keys
		updateKeys { result in

			self.issuerPublicKeysStatus = result
			self.handleState()
		}
	}

	/// Handle the state of the updates
	private func handleState() {

		guard let configStatus = configStatus,
			  let issuerPublicKeysStatus = issuerPublicKeysStatus else {
			return
		}

		logVerbose("switch \(configStatus), \(issuerPublicKeysStatus) - didFinishLaunchState: \(didFinishLaunchState)")

		// Small delay, let the viewController load.
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			switch (configStatus, issuerPublicKeysStatus) {
				case (.withinTTL, .withinTTL):
					self.didFinishLaunchState = true
					self.coordinator?.handleLaunchState(.withinTTL)

				case (.actionRequired, _):
					self.coordinator?.handleLaunchState(configStatus)

				case (LaunchState.internetRequired, _), (_, .internetRequired):
					if !self.didFinishLaunchState {
						self.didFinishLaunchState = true
						self.coordinator?.handleLaunchState(.internetRequired)
					}

				case (.noActionNeeded, .noActionNeeded), (.noActionNeeded, .withinTTL), (.withinTTL, .noActionNeeded):
					if let lib = self.cryptoLibUtility, !lib.isInitialized {
						// Show crypto lib not initialized error
						self.coordinator?.handleLaunchState(.cryptoLibNotInitialized)
					} else {
						// Start application
						if !self.didFinishLaunchState {
							self.didFinishLaunchState = true
							self.coordinator?.handleLaunchState(.noActionNeeded)
						}
					}

				default:
					self.logWarning("Unhandled \(configStatus), \(issuerPublicKeysStatus)")
			}
		}
	}

	/// Update the configuration
	private func updateConfiguration(_ completion: @escaping (LaunchState) -> Void) {

		// Execute once.
		guard !isUpdatingConfiguration else {
			return
		}

		isUpdatingConfiguration = true

		if let lastFetchedTimestamp = self.userSettings?.configFetchedTimestamp,
		   lastFetchedTimestamp > Date().timeIntervalSince1970 - TimeInterval(remoteConfigManager?.storedConfiguration.configTTL ?? 0) {
			self.logInfo("Remote Configuration still within TTL")
			// Mark remote config loaded
			cryptoLibUtility?.checkFile(.remoteConfiguration)
			completion(.withinTTL)
		}

		remoteConfigManager?.update { resultWrapper in

			self.isUpdatingConfiguration = false
			switch resultWrapper {
				case let .success((remoteConfiguration, data, urlResponse)):

					// Update the last fetch time
					self.userSettings?.configFetchedTimestamp = Date().timeIntervalSince1970
					self.userSettings?.configFetchedHash = {
						guard let string = String(data: data, encoding: .utf8) else { return nil }
						return string.sha256
					}()

					// Store as JSON file
					self.cryptoLibUtility?.store(data, for: .remoteConfiguration)
					// Check the wallet
					self.checkWallet()

					/// Fish for the server Date in the network response, and use that to maintain
					/// a clockDeviationManager to check if the delta between the serverTime and the localTime is
					/// beyond a permitted time interval.
					if let httpResponse = urlResponse as? HTTPURLResponse,
					   let serverDateString = httpResponse.allHeaderFields["Date"] as? String {
						Services.clockDeviationManager.update(
							serverHeaderDate: serverDateString,
							ageHeader: httpResponse.allHeaderFields["Age"] as? String
						)
					}

					self.compare(remoteConfiguration, completion: completion)

				case let .failure(networkError):

					self.logError("Error retreiving remote configuration: \(networkError.localizedDescription)")

					// Fallback to the last known remote configuration
					guard let storedConfiguration = self.remoteConfigManager?.storedConfiguration else {
						completion(.internetRequired)
						return
					}

					self.logDebug("Using stored Configuration \(storedConfiguration)")

					// Check the wallet
					self.checkWallet()

					self.compare(storedConfiguration) { state in
						switch state {
							case .actionRequired:
								// Deactivated or update trumps no internet
								completion(state)
							default:
								completion(.internetRequired)
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
		_ remoteConfiguration: RemoteConfiguration,
		completion: @escaping (LaunchState) -> Void) {

		let requiredVersion = remoteConfiguration.minimumVersion.fullVersionString()
		let recommendedVersion = remoteConfiguration.recommendedVersion?.fullVersionString() ?? "1.0.0"
		let currentVersion = versionSupplier?.getCurrentVersion().fullVersionString() ?? "1.0.0"

		if remoteConfiguration.isDeactivated ||
			requiredVersion.compare(currentVersion, options: .numeric) == .orderedDescending ||
			recommendedVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
			// Update or kill the app
			completion(.actionRequired(remoteConfiguration))
		} else {
			// Nothing to do
			completion(.noActionNeeded)
		}
	}

	private func checkWallet() {

		guard let configuration = remoteConfigManager?.storedConfiguration else {
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

		if let lastFetchedTimestamp = self.userSettings?.issuerKeysFetchedTimestamp,
		   lastFetchedTimestamp > Date().timeIntervalSince1970 - TimeInterval(remoteConfigManager?.storedConfiguration.configTTL ?? 0) {
			self.logInfo("Issuer public keys still within TTL")
			// Mark remote config loaded
			cryptoLibUtility?.checkFile(.publicKeys)
			completion(.withinTTL)
		}
		proofManager?.fetchIssuerPublicKeys {[weak self] resultWrapper in

			self?.isUpdatingIssuerPublicKeys = false

			// Response is of type (Result<Data, NetworkError>)
			switch resultWrapper {
				case .success(let data):

					// Update the last fetch time
					self?.userSettings?.issuerKeysFetchedTimestamp = Date().timeIntervalSince1970
					// Store JSON file
					self?.cryptoLibUtility?.store(data, for: .publicKeys)

					completion(.noActionNeeded)

				case let .failure(error):

					self?.logError("Error getting the issuers public keys: \(error)")
					completion(.internetRequired)
			}
		}
	}

	// MARK: Jailbreak

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

	func showJailBreakAlert() {

		alert = AlertContent(
			title: L.jailbrokenTitle(),
			subTitle: L.jailbrokenMessage(),
			cancelAction: nil,
			cancelTitle: nil,
			okAction: { [weak self] _ in
				self?.userDismissedJailBreakWarning()
			},
			okTitle: L.generalOk()
		)
	}

	func userDismissedJailBreakWarning() {

		// Interruption is over
		alert = nil
		// Warning has been shown, do not show twice
		userSettings?.jailbreakWarningShown = true
		// Continue with flow
		startChecks()
	}

	// MARK: DeviceAuthentication

	private func shouldShowDeviceAuthenticationAlert() -> Bool {

		guard flavor == .holder else {
			// Only enable for the holder
			return false
		}

		guard let deviceAuthenticationDetector = deviceAuthenticationDetector, let userSettings = userSettings else {
			return false
		}

		return !userSettings.deviceAuthenticationWarningShown && !deviceAuthenticationDetector.hasAuthenticationPolicy()
	}

	func showDeviceAuthenticationAlert() {

		alert = AlertContent(
			title: L.holderDeviceAuthenticationWarningTitle(),
			subTitle: L.holderDeviceAuthenticationWarningMessage(),
			cancelAction: nil,
			cancelTitle: nil,
			okAction: { [weak self] _ in
				self?.userDismissedDeviceAuthenticationWarning()
			},
			okTitle: L.generalOk()
		)
	}

	func userDismissedDeviceAuthenticationWarning() {

		// Interruption is over
		alert = nil
		// Warning has been shown, do not show twice
		userSettings?.deviceAuthenticationWarningShown = true
		// Continue with flow
		startChecks()
	}
}

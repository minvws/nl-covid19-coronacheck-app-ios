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
	private var walletManager: WalletManaging?
	private var versionSupplier: AppVersionSupplierProtocol?

	private var isUpdatingConfiguration = false
	private var isUpdatingIssuerPublicKeys = false

	private var flavor: AppFlavor
	var configStatus: LaunchState?
	var issuerPublicKeysStatus: LaunchState?
	var didFinishLaunchState = false

	private var remoteConfigManagerUpdateToken: RemoteConfigManager.ObserverToken?

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
		flavor: AppFlavor) {

		self.coordinator = coordinator
		self.versionSupplier = versionSupplier
		self.flavor = flavor

		title = flavor == .holder ? L.holderLaunchTitle() : L.verifierLaunchTitle()
		message = flavor == .holder ? L.holderLaunchText() : L.verifierLaunchText()
		appIcon = flavor == .holder ? I.holderAppIcon() : I.verifierAppIcon()

		version = flavor == .holder
			? L.holderLaunchVersion(versionSupplier?.getCurrentVersion() ?? "", versionSupplier?.getCurrentBuild() ?? "")
			: L.verifierLaunchVersion(versionSupplier?.getCurrentVersion() ?? "", versionSupplier?.getCurrentBuild() ?? "")

		walletManager = flavor == .holder ? Current.walletManager : nil

		remoteConfigManagerUpdateToken = Current.remoteConfigManager.appendReloadObserver { [weak self] remoteConfig, rawData, urlResponse in
			Current.cryptoLibUtility.checkFile(.remoteConfiguration)
			self?.checkWallet()
		}

		startChecks()
	}

	deinit {
		remoteConfigManagerUpdateToken.map {
			Current.remoteConfigManager.removeObserver(token: $0)
		}
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
					if !Current.cryptoLibUtility.isInitialized {
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
		guard !isUpdatingConfiguration else { return }
		isUpdatingConfiguration = true

		Current.remoteConfigManager.update(
			isAppLaunching: true,
			immediateCallbackIfWithinTTL: {
				Current.cryptoLibUtility.checkFile(.remoteConfiguration)
				completion(.withinTTL)
			},
			completion: { (result: Result<(Bool, RemoteConfiguration), ServerError>) in
				self.isUpdatingConfiguration = false
				switch result {
					case let .success((_, remoteConfiguration)):

						// Note: There are also other steps done on completion
						// by way of the remoteConfigManager's registered update/reload observers
						// - see RemoteConfigManager `.appendUpdateObserver` and `.appendReloadObserver`.

						self.compare(remoteConfiguration, completion: completion)

					case let .failure(networkError):
						self.logError("Error retreiving remote configuration: \(networkError.localizedDescription)")

						// Fallback to the last known remote configuration
						let storedConfiguration = Current.remoteConfigManager.storedConfiguration
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
			})
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

		let configuration = Current.remoteConfigManager.storedConfiguration

		walletManager?.expireEventGroups(
			vaccinationValidity: (configuration.vaccinationEventValidityDays ?? 730) * 24,
			recoveryValidity: (configuration.recoveryEventValidityDays ?? 365) * 24,
			testValidity: configuration.testEventValidityHours
		)
	}

	private func updateKeys(_ completion: @escaping (LaunchState) -> Void) {

		// Execute once.
		guard !isUpdatingIssuerPublicKeys else { return }
		isUpdatingIssuerPublicKeys = true

		Current.cryptoLibUtility.update(
			isAppLaunching: true,
			immediateCallbackIfWithinTTL: {
				Current.cryptoLibUtility.checkFile(.publicKeys)
				completion(.withinTTL)
			},
			completion: { (result: Result<Bool, ServerError>) in
				self.isUpdatingIssuerPublicKeys = false
				switch result {
					case .success:
						completion(.noActionNeeded)

					case let .failure(error):
						self.logError("Error getting the issuers public keys: \(error)")
						completion(.internetRequired)
				}
			}
		)
	}

	// MARK: Jailbreak

	private func shouldShowJailBreakAlert() -> Bool {

		guard flavor == .holder else {
			// Only enable for the holder
			return false
		}
		
		return !Current.userSettings.jailbreakWarningShown && Current.jailBreakDetector.isJailBroken()
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
		Current.userSettings.jailbreakWarningShown = true
		// Continue with flow
		startChecks()
	}

	// MARK: DeviceAuthentication

	private func shouldShowDeviceAuthenticationAlert() -> Bool {

		guard flavor == .holder else {
			// Only enable for the holder
			return false
		}

		// Does the device have a pin/touch/face authentication? (show only once)
		return !Current.userSettings.deviceAuthenticationWarningShown && !Current.deviceAuthenticationDetector.hasAuthenticationPolicy()
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
		Current.userSettings.deviceAuthenticationWarningShown = true
		// Continue with flow
		startChecks()
	}
}

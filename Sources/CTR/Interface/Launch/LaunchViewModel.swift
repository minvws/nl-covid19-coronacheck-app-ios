/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LaunchViewModel {

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
		remoteConfigManager?.update { state in

			self.isUpdatingConfiguration = false
			completion(state)
		}
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

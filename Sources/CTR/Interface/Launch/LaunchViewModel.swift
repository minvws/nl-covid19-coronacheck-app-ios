/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LaunchViewModel {

	private weak var coordinator: AppCoordinatorDelegate?

	private var versionSupplier: AppVersionSupplierProtocol
	private var remoteConfigManager: RemoteConfigManaging
	private var proofManager: ProofManaging
	private var jailBreakDetector: JailBreakProtocol

	private var isUpdatingConfiguration = false
	private var isUpdatingIssuerPublicKeys = false
	private var configStatus: LaunchState?
	private var issuerPublicKeysStatus: LaunchState?
	private var flavor: AppFlavor

	/// The title of the launch page
	@Bindable private(set) var title: String

	/// The message of the launch page
	@Bindable private(set) var message: String

	/// The version of the launch page
	@Bindable private(set) var version: String

	/// The icon of the launch page
	@Bindable private(set) var appIcon: UIImage?

	/// Should we show the jailbreak warning?
	@Bindable private(set) var shouldShowJailBreakDialog: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - versionSupplier: the version supplier
	///   - flavor: the app flavor (holder or verifier)
	init(
		coordinator: AppCoordinatorDelegate,
		versionSupplier: AppVersionSupplierProtocol,
		flavor: AppFlavor,
		remoteConfigManager: RemoteConfigManaging,
		proofManager: ProofManaging,
		jailBreakDetector: JailBreakProtocol = JailBreakDetector()) {

		self.coordinator = coordinator
		self.versionSupplier = versionSupplier
		self.remoteConfigManager = remoteConfigManager
		self.proofManager = proofManager
		self.flavor = flavor
		self.jailBreakDetector = jailBreakDetector

		title = flavor == .holder ? .holderLaunchTitle : .verifierLaunchTitle
		message = flavor == .holder  ? .holderLaunchText : .verifierLaunchText
		appIcon = flavor == .holder ? .holderAppIcon : .verifierAppIcon

		let versionString: String = flavor == .holder ? .holderLaunchVersion : .verifierLaunchVersion
		version = String(
			format: versionString,
			versionSupplier.getCurrentVersion(),
			versionSupplier.getCurrentBuild()
		)
	}

	/// Check the requirements
	func checkRequirements() {

		detectJailBreak()
		updateConfiguration()
		updateKeys()
	}

	func jailBreakWarningDismissed() {

		jailBreakDetector.warningHasBeenSeen()
		shouldShowJailBreakDialog = false
		handleState()
	}

	private func detectJailBreak() {

		guard flavor == .holder else {
			// Only enable for the holder
			shouldShowJailBreakDialog = false
			return
		}

		if jailBreakDetector.shouldWarnUser() && jailBreakDetector.isJailBroken() {
			shouldShowJailBreakDialog = true
		}
	}

	/// Update the configuration
	private func updateConfiguration() {

		// Execute once.
		guard !isUpdatingConfiguration else {
			return
		}

		isUpdatingConfiguration = true

		remoteConfigManager.update { [weak self] updateState in

			self?.configStatus = updateState
			self?.isUpdatingConfiguration = false
			self?.handleState()
		}
	}

	/// Update the Issuer Public keys
	private func updateKeys() {

		// Execute once.
		guard !isUpdatingIssuerPublicKeys else {
			return
		}

		isUpdatingIssuerPublicKeys = true

		// Fetch the issuer Public keys
		proofManager.fetchIssuerPublicKeys { [weak self] in

			self?.isUpdatingIssuerPublicKeys = false
			self?.issuerPublicKeysStatus = .noActionNeeded
			self?.handleState()

		} onError: { [weak self] error in

			self?.isUpdatingIssuerPublicKeys = false
			self?.issuerPublicKeysStatus = .internetRequired
			self?.handleState()
		}
	}

	/// Handle the state of the updates
	private func handleState() {

		guard let configStatus = configStatus,
			  let issuerPublicKeysStatus = issuerPublicKeysStatus,
			  !shouldShowJailBreakDialog else {
			return
		}

		if case .actionRequired = configStatus {
			// show action
			coordinator?.handleLaunchState(configStatus)
		} else if configStatus == .internetRequired || issuerPublicKeysStatus == .internetRequired {
			// Show no internet
			coordinator?.handleLaunchState(.internetRequired)
		} else {
			// Start application
			coordinator?.handleLaunchState(.noActionNeeded)
		}
	}
}

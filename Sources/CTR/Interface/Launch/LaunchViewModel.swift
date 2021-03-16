/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LaunchViewModel: Logging {

	/// The logging Category
	var loggingCategory: String = "LaunchViewModel"

	/// App Coordinator Delegate
	weak var coordinator: AppCoordinatorDelegate?

	/// The current app version supplier
	var versionSupplier: AppVersionSupplierProtocol

	/// The remote config manager
	var remoteConfigManager: RemoteConfigManaging

	/// The proof manager
	var proofManager: ProofManaging

	/// flag for updating configuration
	private var isUpdatingConfiguration = false

	/// flag for updating public keys
	private var isUpdatingIssuerPublicKeys = false

	/// The launch state of the configuration
	private var configStatus: LaunchState?

	/// The launch state of the issuer public keys
	private var issuerPublicKeysStatus: LaunchState?

	/// The title of the launch page
	@Bindable private(set) var title: String

	/// The message of the launch page
	@Bindable private(set) var message: String

	/// The version of the launch page
	@Bindable private(set) var version: String

	/// The icon of the launch page
	@Bindable private(set) var appIcon: UIImage?

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
		proofManager: ProofManaging) {

		self.coordinator = coordinator
		self.versionSupplier = versionSupplier
		self.remoteConfigManager = remoteConfigManager
		self.proofManager = proofManager

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

		logInfo("Checking Requirements")
		updateConfiguration()
		updateKeys()
	}

	/// Update the configuration
	func updateConfiguration() {

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
	func updateKeys() {

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
	func handleState() {

		guard let configStatus = configStatus,
			  let issuerPublicKeysStatus = issuerPublicKeysStatus else {
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

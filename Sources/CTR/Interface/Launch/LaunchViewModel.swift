/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import LocalAuthentication

class LaunchViewModel {

	private weak var coordinator: AppCoordinatorDelegate?

	private var isUpdatingConfiguration = false
	private var isUpdatingIssuerPublicKeys = false

	private var flavor: AppFlavor
	var configStatus: LaunchState?
	var issuerPublicKeysStatus: LaunchState?

	@Bindable private(set) var message: String
	@Bindable private(set) var appIcon: UIImage?
	@Bindable private(set) var alert: AlertContent?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - flavor: the app flavor (holder or verifier)
	init(
		coordinator: AppCoordinatorDelegate,
		flavor: AppFlavor
	) {

		self.coordinator = coordinator
		self.flavor = flavor

		message = flavor == .holder ? L.holderLaunchText() : L.verifierLaunchText()
		appIcon = flavor == .holder ? I.launch.holderAppIcon() : I.launch.verifierAppIcon()

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

		// Small delay, let the viewController load.
		DispatchQueue.main.asyncAfter(deadline: .now() + (ProcessInfo().isUnitTesting ? 0 : 0.5)) {
			switch (configStatus, issuerPublicKeysStatus) {
				case (.withinTTL, .withinTTL):
					self.coordinator?.handleLaunchState(.withinTTL)
								
				case let (.serverError(error1), .serverError(error2)):
					self.coordinator?.handleLaunchState(.serverError(error1 + error2))
				
				case (.serverError(let error), _), (_, .serverError(let error)):
					self.coordinator?.handleLaunchState(.serverError(error))
				
				case (.finished, .finished), (.finished, .withinTTL), (.withinTTL, .finished):
					self.coordinator?.handleLaunchState(.finished)
					
				default:
					logWarning("Unhandled \(configStatus), \(issuerPublicKeysStatus)")
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

					case .success:
						completion(.finished)

					case let .failure(error):
						logError("Error getting the remote config: \(error)")
						completion(.serverError([error]))
				}
			})
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
						completion(.finished)

					case let .failure(error):
						logError("Error getting the issuers public keys: \(error)")
						completion(.serverError([error]))
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
			okAction: AlertContent.Action(
				title: L.generalOk(),
				action: { [weak self] _ in
					self?.userDismissedJailBreakWarning()
				}
			)
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

	// MARK: DeviceAuthentication (pin code)

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
			okAction: AlertContent.Action(
				title: L.generalOk(),
				action: { [weak self] _ in
					self?.userDismissedDeviceAuthenticationWarning()
				}
			)
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

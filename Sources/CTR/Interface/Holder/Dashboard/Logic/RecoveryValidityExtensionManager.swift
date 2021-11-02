/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol RecoveryValidityExtensionManagerProtocol {
	typealias BannerType = RecoveryValidityExtensionManager.BannerType

	var bannerStateCallback: ((BannerType?) -> Void)? { get set }

	func reload()
}

final class RecoveryValidityExtensionManager: RecoveryValidityExtensionManagerProtocol {

	enum BannerType: Equatable {
		/// The recovery certificate you have can be extended
		case extensionAvailable
		/// The recovery certificate you had (which expired)
		/// can be reinstated due to an extending of the rules.
		case reinstationAvailable

		case extensionDidComplete
		case reinstationDidComplete
	}

	// Callbacks:
	var bannerStateCallback: ((BannerType?) -> Void)?

	// State:
	private(set) var isLoading = false

	// Dependencies:
	private let userHasRecoveryEvents: () -> Bool
	private let userHasUnexpiredRecoveryGreencards: () -> Bool
	private let userSettings: UserSettingsProtocol
	private let remoteConfigManager: RemoteConfigManaging
	private let now: () -> Date

	init(
		userHasRecoveryEvents: @escaping () -> Bool,
		userHasUnexpiredRecoveryGreencards: @escaping () -> Bool,
		userSettings: UserSettingsProtocol,
		remoteConfigManager: RemoteConfigManaging,
		now: @escaping () -> Date
	) {
		self.userHasRecoveryEvents = userHasRecoveryEvents
		self.userHasUnexpiredRecoveryGreencards = userHasUnexpiredRecoveryGreencards
		self.userSettings = userSettings
		self.remoteConfigManager = remoteConfigManager
		self.now = now
	}

	func reload() {
		guard !isLoading else { return }
		isLoading = true
		defer {
			isLoading = false
		}

		// If no way to callback to user, exit.
		guard let bannerStateCallback = bannerStateCallback,
			  let featureLaunchDate = remoteConfigManager.storedConfiguration.recoveryGreencardRevisedValidityLaunchDate
		else { return }

		// If feature not launched yet, exit.
		guard featureLaunchDate < now() else { return }

		// If no recovery events, exit.
		guard userHasRecoveryEvents() else {
			// we're already past the launch date and the user doesn't have any recovery
			// events, so this feature can now be permanently disabled:
			userSettings.shouldCheckRecoveryGreenCardRevisedValidity = false
			return
		}

		if userSettings.shouldCheckRecoveryGreenCardRevisedValidity {

			let userHasUnexpiredRecoveryGreencards = self.userHasUnexpiredRecoveryGreencards()
			userSettings.shouldShowRecoveryValidityExtensionCard = userHasUnexpiredRecoveryGreencards
			userSettings.shouldShowRecoveryValidityReinstationCard = !userHasUnexpiredRecoveryGreencards

			// The above check should just be done once. Close this check:
			userSettings.shouldCheckRecoveryGreenCardRevisedValidity = false
		}

		// Callback with banner type:
		bannerStateCallback(calculateBannerState())
	}

	private func calculateBannerState() -> BannerType? {
		if userSettings.shouldShowRecoveryValidityExtensionCard {
			return .extensionAvailable
		} else if userSettings.shouldShowRecoveryValidityReinstationCard {
			return BannerType.reinstationAvailable
		}

		guard userHasUnexpiredRecoveryGreencards() else { return nil }

		if !userSettings.hasDismissedRecoveryValidityExtensionCompletionCard {
			return BannerType.extensionDidComplete
		} else if !userSettings.hasDismissedRecoveryValidityReinstationCompletionCard {
			return BannerType.reinstationDidComplete
		}
		return nil
	}
}

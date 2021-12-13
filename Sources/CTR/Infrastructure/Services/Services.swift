/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Reachability

/// Global container for the different services used in the app
final class Services {

	private static var appInstalledSinceManagingType: AppInstalledSinceManaging.Type = AppInstalledSinceManager.self
	private static var cryptoLibUtilityType: CryptoLibUtilityProtocol.Type = CryptoLibUtility.self
	private static var cryptoManagingType: CryptoManaging.Type = CryptoManager.self
	private static var dataStoreManagingType: DataStoreManaging.Type = DataStoreManager.self
	private static var deviceAuthenticationType: DeviceAuthenticationProtocol.Type = DeviceAuthenticationDetector.self
	private static var featureFlagManagingType: FeatureFlagManaging.Type = FeatureFlagManager.self
	private static var forcedInformationManagingType: ForcedInformationManaging.Type = ForcedInformationManager.self
	private static var jailBreakType: JailBreakProtocol.Type = JailBreakDetector.self
	private static var networkManagingType: NetworkManaging.Type = NetworkManager.self
    private static var onboardingManagingType: OnboardingManaging.Type = OnboardingManager.self
	private static var openIdManagerType: OpenIdManaging.Type = OpenIdManager.self
	private static var remoteConfigManagingType: RemoteConfigManaging.Type = RemoteConfigManager.self
	private static var walletManagingType: WalletManaging.Type = WalletManager.self
	private static var greenCardLoadingType: GreenCardLoading.Type = GreenCardLoader.self
	private static var couplingManagingType: CouplingManaging.Type = CouplingManager.self
	private static var mappingManagingType: MappingManaging.Type = MappingManager.self
	private static var clockDeviationType: ClockDeviationManaging.Type = ClockDeviationManager.self
	private static var riskLevelManagerType: RiskLevelManaging.Type = RiskLevelManager.self
	private static var scanLockManagerType: ScanLockManaging.Type = ScanLockManager.self
	private static var scanLogManagingType: ScanLogManaging.Type = ScanLogManager.self

	// MARK: use override for testing

	static func use(_ appInstalledSinceManaging: AppInstalledSinceManaging) {

		appInstalledSinceManager = appInstalledSinceManaging
	}

	static func use(_ cryptoManaging: CryptoManaging) {

		cryptoManager = cryptoManaging
	}

	static func use(_ cryptoUtilityProtocol: CryptoLibUtilityProtocol) {

		cryptoLibUtility = cryptoUtilityProtocol
	}

	static func use(_ deviceAuthenticationProtocol: DeviceAuthenticationProtocol) {

		deviceAuthenticationDetector = deviceAuthenticationProtocol
	}

	static func use(_ jailBreakProtocol: JailBreakProtocol) {

		jailBreakDetector = jailBreakProtocol
	}

	static func use(_ featureFlagManaging: FeatureFlagManaging) {

		featureFlagManager = featureFlagManaging
	}

	static func use(_ forcedInformationManaging: ForcedInformationManaging) {

		forcedInformationManager = forcedInformationManaging
	}

    static func use(_ networkManaging: NetworkManaging) {

        networkManager = networkManaging
    }

    static func use(_ remoteConfigManaging: RemoteConfigManaging) {

		remoteConfigManager = remoteConfigManaging
    }

    static func use(_ onboardingManaging: OnboardingManaging) {

		onboardingManager = onboardingManaging
    }

	static func use(_ openIdManaging: OpenIdManaging) {

		openIdManager = openIdManaging
	}

	static func use(_ greenCardLoading: GreenCardLoading) {

		greenCardLoader = greenCardLoading
	}

	static func use(_ couplingManaging: CouplingManaging) {

		couplingManager = couplingManaging
	}

	static func use(_ mappingManaging: MappingManaging) {

		mappingManager = mappingManaging
	}

	static func use(_ clockDeviationManaging: ClockDeviationManaging) {

		clockDeviationManager = clockDeviationManaging
	}

	static func use(_ scanLockManaging: ScanLockManaging) {

		scanLockManager = scanLockManaging
	}

	static func use(_ walletManaging: WalletManaging) {

		walletManager = walletManaging
	}

	static func use(_ scanLogManaging: ScanLogManaging) {

		scanLogManager = scanLogManaging
	}

	static func use(_ riskLevelManaging: RiskLevelManaging) {

		riskLevelManager = riskLevelManaging
	}

	// MARK: Static access
    
    static private(set) var networkManager: NetworkManaging = {
        let networkConfiguration: NetworkConfiguration

        let configurations: [String: NetworkConfiguration] = [
            NetworkConfiguration.development.name: NetworkConfiguration.development,
            NetworkConfiguration.acceptance.name: NetworkConfiguration.acceptance,
            NetworkConfiguration.production.name: NetworkConfiguration.production
        ]

        let fallbackConfiguration = NetworkConfiguration.development

        if let networkConfigurationValue = Bundle.main.infoDictionary?["NETWORK_CONFIGURATION"] as? String {
            networkConfiguration = configurations[networkConfigurationValue] ?? fallbackConfiguration
        } else {
            networkConfiguration = fallbackConfiguration
        }
        
        return networkManagingType.init(configuration: networkConfiguration)
    }()

	static private(set) var appInstalledSinceManager: AppInstalledSinceManaging = appInstalledSinceManagingType.init()
	static private(set) var cryptoLibUtility: CryptoLibUtilityProtocol = cryptoLibUtilityType.init(
		now: { Date() },
		userSettings: UserSettings(),
		reachability: try? Reachability(),
		fileStorage: FileStorage(),
		flavor: AppFlavor.flavor
	)
	static private(set) var cryptoManager: CryptoManaging = cryptoManagingType.init()
	static private(set) var deviceAuthenticationDetector: DeviceAuthenticationProtocol = deviceAuthenticationType.init()
	static private(set) var dataStoreManager: DataStoreManaging = dataStoreManagingType.init(
		StorageType.persistent,
		flavor: AppFlavor.flavor
	)
	static private(set) var featureFlagManager: FeatureFlagManaging = featureFlagManagingType.init()
	static private(set) var forcedInformationManager: ForcedInformationManaging = forcedInformationManagingType.init()
	static private(set) var jailBreakDetector: JailBreakProtocol = jailBreakType.init()
	static private(set) var greenCardLoader: GreenCardLoading = greenCardLoadingType.init(
		networkManager: networkManager,
		cryptoManager: cryptoManager,
		walletManager: walletManager
	)
    static private(set) var remoteConfigManager: RemoteConfigManaging = remoteConfigManagingType.init(
		now: { Date() },
		userSettings: UserSettings(),
		reachability: try? Reachability(),
		networkManager: networkManager
	)
	static private(set) var onboardingManager: OnboardingManaging = onboardingManagingType.init()
	static private(set) var openIdManager: OpenIdManaging = openIdManagerType.init()
	static private(set) var walletManager: WalletManaging = walletManagingType.init(
		dataStoreManager: dataStoreManager
	)
	static private(set) var couplingManager: CouplingManaging = couplingManagingType.init(
		cryptoManager: cryptoManager,
		networkManager: networkManager
	)
	static private(set) var mappingManager: MappingManaging = mappingManagingType.init(
		remoteConfigManager: remoteConfigManager
	)
	static private(set) var clockDeviationManager: ClockDeviationManaging = clockDeviationType.init()
	static private(set) var scanLockManager: ScanLockManaging = scanLockManagerType.init()
	static private(set) var riskLevelManager: RiskLevelManaging = riskLevelManagerType.init()
	static private(set) var scanLogManager: ScanLogManaging = scanLogManagingType.init(
		dataStoreManager: dataStoreManager
	)

	/// Reset all the data
	static func reset(flavor: AppFlavor) {

		appInstalledSinceManager.reset()
		onboardingManager.reset()
		remoteConfigManager.reset()
		cryptoLibUtility.reset()
		forcedInformationManager.reset()

		switch flavor {
			case .holder:
				walletManager.removeExistingEventGroups()
				walletManager.removeExistingGreenCards()
			case .verifier:
				riskLevelManager.reset()
				scanLockManager.reset()
				scanLogManager.reset()
		}
	}

	static func revertToDefaults() {

		appInstalledSinceManager = appInstalledSinceManagingType.init()
		cryptoManager = cryptoManagingType.init()
		deviceAuthenticationDetector = deviceAuthenticationType.init()
		dataStoreManager = dataStoreManagingType.init(StorageType.persistent, flavor: AppFlavor.flavor)
		walletManager = walletManagingType.init(
			dataStoreManager: dataStoreManager
		)
		featureFlagManager = featureFlagManagingType.init()
		forcedInformationManager = forcedInformationManagingType.init()
		jailBreakDetector = jailBreakType.init()
		greenCardLoader = greenCardLoadingType.init(
			networkManager: networkManager,
			cryptoManager: cryptoManager,
			walletManager: walletManager
		)
		remoteConfigManager = remoteConfigManagingType.init(
			now: { Date() },
			userSettings: UserSettings(),
			reachability: try? Reachability(),
			networkManager: networkManager
		)
		onboardingManager = onboardingManagingType.init()
		openIdManager = openIdManagerType.init()

		couplingManager = couplingManagingType.init(
			cryptoManager: cryptoManager,
			networkManager: networkManager
		)
		mappingManager = mappingManagingType.init(
			remoteConfigManager: remoteConfigManager
		)
		clockDeviationManager = clockDeviationType.init()
		cryptoLibUtility = cryptoLibUtilityType.init(
			now: { Date() },
			userSettings: UserSettings(),
			reachability: try? Reachability(),
			fileStorage: FileStorage(),
			flavor: AppFlavor.flavor
		)
		scanLockManager = scanLockManagerType.init()
		scanLogManager = scanLogManagingType.init(
			dataStoreManager: dataStoreManager
		)
		riskLevelManager = riskLevelManagerType.init()
	}
}

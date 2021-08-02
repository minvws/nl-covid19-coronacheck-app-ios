/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

/// Global container for the different services used in the app
final class Services {
	
	private static var cryptoLibUtilityType: CryptoLibUtility.Type = CryptoLibUtility.self
	private static var cryptoManagingType: CryptoManaging.Type = CryptoManager.self
	private static var dataStoreManagingType: DataStoreManaging.Type = DataStoreManager.self
	private static var forcedInformationManagingType: ForcedInformationManaging.Type = ForcedInformationManager.self
	private static var networkManagingType: NetworkManaging.Type = NetworkManager.self
    private static var onboardingManagingType: OnboardingManaging.Type = OnboardingManager.self
	private static var openIdManagerType: OpenIdManaging.Type = OpenIdManager.self
	private static var proofManagerType: ProofManaging.Type = ProofManager.self
	private static var remoteConfigManagingType: RemoteConfigManaging.Type = RemoteConfigManager.self
	private static var walletManagingType: WalletManaging.Type = WalletManager.self
	private static var greenCardLoadingType: GreenCardLoading.Type = GreenCardLoader.self
	private static var couplingManagingType: CouplingManaging.Type = CouplingManager.self
	private static var mappingManagingType: MappingManaging.Type = MappingManager.self

	/// Override the CryptoManaging type that will be instantiated
	/// - parameter cryptoManager: The type conforming to CryptoManaging to be used as the global cryptoManager
	static func use(_ cryptoManager: CryptoManaging.Type) {

		cryptoManagingType = cryptoManager
	}

	/// Override the ForcedInformationManaging type that will be instantiated
	/// - parameter forcedInformationManager: The type conforming to ForcedInformationManaging to be used as the global forcedInformationManager
	static func use(_ forcedInformationManager: ForcedInformationManaging.Type) {

		forcedInformationManagingType = forcedInformationManager
	}

    /// Override the NetworkManaging type that will be instantiated
    /// - parameter networkManager: The type conforming to NetworkManaging to be used as the global networkManager
    static func use(_ networkManager: NetworkManaging.Type) {

        networkManagingType = networkManager
    }

    /// Override the RemoteConfigManaging type that will be instantiated
    /// - parameter configManager: The type conforming to RemoteConfigManaging to be used as the global configManager
    static func use(_ configManager: RemoteConfigManaging.Type) {

		remoteConfigManagingType = configManager
    }

    /// Override the OnboardingManaging type that will be instantiated
    /// - parameter onboardingManaging: The type conforming to OnboardingManaging to be used as the global onboardingManager
    static func use(_ onboardingManager: OnboardingManaging.Type) {
        onboardingManagingType = onboardingManager
    }

	/// Override the OpenIdManaging type that will be instantiated
	/// - parameter openIdManager: The type conforming to OpenIdManaging to be used as the global openID manager
	static func use(_ openIdManager: OpenIdManaging.Type) {
		openIdManagerType = openIdManager
	}

	/// Override the ProofManaging type that will be instantiated
	/// - parameter proofManager: The type conforming to ProofManaging to be used as the global proof manager
	static func use(_ proofManager: ProofManaging.Type) {
		proofManagerType = proofManager
	}

	/// Override the GreenCardLoading type that will be instantiated
	/// - parameter greenCardLoader: The type conforming to GreenCardLoading to be used as the global greencard loader
	static func use(_ greenCardLoader: GreenCardLoading.Type) {
		greenCardLoadingType = greenCardLoader
	}

	/// Override the couplingManaging type  that will be instantiated
	/// - parameter couplingManager: The type conforming to CouplingManaging to be used as the global coupling manager
	static func use(_ couplingManager: CouplingManaging.Type) {
		couplingManagingType = couplingManager
	}

	/// Override the mappingManaging type  that will be instantiated
	/// - parameter mappingManager: The type conforming to MappingManaging to be used as the global mapping manager
	static func use(_ mappingManager: MappingManaging.Type) {
		mappingManagingType = mappingManager
	}

	// MARK: Static access
    
    static private(set) var networkManager: NetworkManaging = {
        let networkConfiguration: NetworkConfiguration

        let configurations: [String: NetworkConfiguration] = [
            NetworkConfiguration.development.name: NetworkConfiguration.development,
            NetworkConfiguration.test.name: NetworkConfiguration.test,
            NetworkConfiguration.acceptance.name: NetworkConfiguration.acceptance,
            NetworkConfiguration.production.name: NetworkConfiguration.production
        ]

        let fallbackConfiguration = NetworkConfiguration.test

        if let networkConfigurationValue = Bundle.main.infoDictionary?["NETWORK_CONFIGURATION"] as? String {
            networkConfiguration = configurations[networkConfigurationValue] ?? fallbackConfiguration
        } else {
            networkConfiguration = fallbackConfiguration
        }
        
        return networkManagingType.init(configuration: networkConfiguration)
    }()

	static private(set) var cryptoLibUtility: CryptoLibUtility = cryptoLibUtilityType.init()

	static private(set) var cryptoManager: CryptoManaging = cryptoManagingType.init()
	
	static private(set) var dataStoreManager: DataStoreManaging = dataStoreManagingType.init(StorageType.persistent)

	static private(set) var forcedInformationManager: ForcedInformationManaging = forcedInformationManagingType.init()

	static private(set) var greenCardLoader: GreenCardLoading = greenCardLoadingType.init(
		networkManager: networkManager,
		cryptoManager: cryptoManager,
		walletManager: walletManager
	)

    static private(set) var remoteConfigManager: RemoteConfigManaging = remoteConfigManagingType.init()

	static private(set) var onboardingManager: OnboardingManaging = onboardingManagingType.init()

	static private(set) var openIdManager: OpenIdManaging = openIdManagerType.init()

	static private(set) var proofManager: ProofManaging = proofManagerType.init()

	static private(set) var walletManager: WalletManaging = walletManagingType.init(dataStoreManager: dataStoreManager)

	static private(set) var couplingManager: CouplingManaging = couplingManagingType.init(
		cryptoManager: cryptoManager,
		networkManager: networkManager
	)

	static private(set) var mappingManager: MappingManaging = mappingManagingType.init(
		remoteConfigManager: remoteConfigManager
	)
}

/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

/// Global container for the different services used in the app
final class Services {
	private static var cryptoManagingType: CryptoManaging.Type = CryptoManager.self
	private static var networkManagingType: NetworkManaging.Type = NetworkManager.self
    private static var onboardingManagingType: OnboardingManaging.Type = OnboardingManager.self
	private static var openIdManagerType: OpenIdManaging.Type = OpenIdManager.self
	private static var proofManagerType: ProofManaging.Type = ProofManager.self
	private static var remoteConfigManagingType: RemoteConfigManaging.Type = RemoteConfigManager.self

	/// Override the [CryptoManaging](x-source-tag://CryptoManaging) type that will be instantiated
	/// - parameter cryptoManager: The type conforming to [CryptoManaging](x-source-tag://CryptoManaging) to be used as the global cryptoManager
	static func use(_ cryptoManager: CryptoManaging.Type) {

		cryptoManagingType = cryptoManager
	}

    /// Override the [NetworkManaging](x-source-tag://NetworkManaging) type that will be instantiated
    /// - parameter networkManager: The type conforming to [NetworkManaging](x-source-tag://NetworkManaging) to be used as the global networkManager
    static func use(_ networkManager: NetworkManaging.Type) {

        networkManagingType = networkManager
    }

    /// Override the [RemoteConfigManaging](x-source-tag://RemoteConfigManaging) type that will be instantiated
    /// - parameter configManager: The type conforming to [RemoteConfigManaging](x-source-tag://RemoteConfigManaging) to be used as the global configManager
    static func use(_ configManager: RemoteConfigManaging.Type) {

		remoteConfigManagingType = configManager
    }

    /// Override the [OnboardingManaging](x-source-tag://OnboardingManaging) type that will be instantiated
    /// - parameter onboardingManaging: The type conforming to [OnboardingManaging](x-source-tag://OnboardingManaging) to be used as the global onboardingManager
    static func use(_ onboardingManager: OnboardingManaging.Type) {
        onboardingManagingType = onboardingManager
    }

	/// Override the [OpenIdManaging](x-source-tag://OpenIdManaging) type that will be instantiated
	/// - parameter openIdManager: The type conforming to [OpenIdManaging](x-source-tag://OpenIdManaging) to be used as the global openID manager
	static func use(_ openIdManager: OpenIdManaging.Type) {
		openIdManagerType = openIdManager
	}

	/// Override the [ProofManaging](x-source-tag://OnboardingManaging) type that will be instantiated
	/// - parameter proofManager: The type conforming to [ProofManaging](x-source-tag://ProofManaging) to be used as the global proof manager
	static func use(_ proofManager: ProofManaging.Type) {
		proofManagerType = proofManager
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

		let validator = CryptoUtility(signatureValidator: SignatureValidator())
        
        return networkManagingType.init(configuration: networkConfiguration, validator: validator)
    }()

	static private(set) var cryptoManager: CryptoManaging = cryptoManagingType.init()

    static private(set) var remoteConfigManager: RemoteConfigManaging = remoteConfigManagingType.init()

	static private(set) var onboardingManager: OnboardingManaging = onboardingManagingType.init()

	static private(set) var openIdManager: OpenIdManaging = openIdManagerType.init()

	static private(set) var proofManager: ProofManaging = proofManagerType.init()
}

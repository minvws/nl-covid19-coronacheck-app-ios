/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Reachability
import Transport
import Shared
import OpenIDConnect
import Persistence
import Managers
import Models

// MARK: - 1: Define the Environment

struct Environment {
	var now: () -> Date
	var appInstalledSinceManager: AppInstalledSinceManaging
	var clockDeviationManager: ClockDeviationManaging
	var contactInformationProvider: ContactInformationProtocol
	var couplingManager: CouplingManaging
	var cryptoLibUtility: CryptoLibUtilityProtocol
	var cryptoManager: CryptoManaging
	var dataStoreManager: DataStoreManaging
	var deviceAuthenticationDetector: DeviceAuthenticationProtocol
	var disclosurePolicyManager: DisclosurePolicyManaging
	var featureFlagManager: FeatureFlagManaging
	var greenCardLoader: GreenCardLoading
	var identityChecker: IdentityCheckerProtocol
	var jailBreakDetector: JailBreakProtocol
	var mappingManager: MappingManaging
	var networkManager: NetworkManaging
	var newFeaturesManager: NewFeaturesManaging
	var onboardingManager: OnboardingManaging
	var openIdManager: OpenIDConnectManaging
	var remoteConfigManager: RemoteConfigManaging
	var verificationPolicyManager: VerificationPolicyManaging
	var scanLockManager: ScanLockManaging
	var scanLogManager: ScanLogManaging
	var secureUserSettings: SecureUserSettingsProtocol
	var userSettings: UserSettingsProtocol
	var walletManager: WalletManaging
	var verificationPolicyEnabler: VerificationPolicyEnableable
	
	init(
		now: @escaping () -> Date,
		appInstalledSinceManager: AppInstalledSinceManaging,
		clockDeviationManager: ClockDeviationManaging,
		contactInformationProvider: ContactInformationProtocol,
		couplingManager: CouplingManaging,
		cryptoLibUtility: CryptoLibUtilityProtocol,
		cryptoManager: CryptoManaging,
		dataStoreManager: DataStoreManaging,
		deviceAuthenticationDetector: DeviceAuthenticationProtocol,
		disclosurePolicyManager: DisclosurePolicyManaging,
		featureFlagManager: FeatureFlagManaging,
		greenCardLoader: GreenCardLoading,
		identityChecker: IdentityCheckerProtocol,
		jailBreakDetector: JailBreakProtocol,
		mappingManager: MappingManaging,
		networkManager: NetworkManaging,
		newFeaturesManager: NewFeaturesManaging,
		onboardingManager: OnboardingManaging,
		openIdManager: OpenIDConnectManaging,
		remoteConfigManager: RemoteConfigManaging,
		verificationPolicyManager: VerificationPolicyManaging,
		scanLockManager: ScanLockManaging,
		scanLogManager: ScanLogManaging,
		secureUserSettings: SecureUserSettingsProtocol,
		userSettings: UserSettingsProtocol,
		walletManager: WalletManaging,
		verificationPolicyEnabler: VerificationPolicyEnableable
	) {
		self.now = now
		self.appInstalledSinceManager = appInstalledSinceManager
		self.clockDeviationManager = clockDeviationManager
		self.contactInformationProvider = contactInformationProvider
		self.couplingManager = couplingManager
		self.cryptoLibUtility = cryptoLibUtility
		self.cryptoManager = cryptoManager
		self.dataStoreManager = dataStoreManager
		self.deviceAuthenticationDetector = deviceAuthenticationDetector
		self.disclosurePolicyManager = disclosurePolicyManager
		self.featureFlagManager = featureFlagManager
		self.greenCardLoader = greenCardLoader
		self.identityChecker = identityChecker
		self.jailBreakDetector = jailBreakDetector
		self.mappingManager = mappingManager
		self.networkManager = networkManager
		self.newFeaturesManager = newFeaturesManager
		self.onboardingManager = onboardingManager
		self.openIdManager = openIdManager
		self.remoteConfigManager = remoteConfigManager
		self.verificationPolicyManager = verificationPolicyManager
		self.scanLockManager = scanLockManager
		self.scanLogManager = scanLogManager
		self.secureUserSettings = secureUserSettings
		self.userSettings = userSettings
		self.walletManager = walletManager
		self.verificationPolicyEnabler = verificationPolicyEnabler
	}
	
	static func setupCurrentEnvironment(completion: @escaping (Result<Environment, Error>) -> Void) {
		
		// Initializing the DataStoreManager is a prerequisite to initializing the Current environment.
		// We need to ensure that the internal setup of DataStoreManager does not fail (e.g. due to a failed DB migration)
		// before we continue booting the application. Otherwise it's non-recoverable.
		
		#if DEBUG
			guard !ProcessInfo().isUnitTesting else { return } // never callback
		#endif
		
		_ = DataStoreManager(.persistent, persistentContainerName: (AppFlavor.flavor == .holder) ? "CoronaCheck" : "Verifier") { result in
			switch result {
				case .success(let dataStoreManager):
					
					// Initialize the global Environment:
					let currentEnvironment = environment(dataStoreManager)
					completion(.success(currentEnvironment))
					
				case .failure(let error):
					completion(.failure(error))
			}
		}
	}
}

// MARK: - 2: Instantiate Private Dependencies

private let appInstalledSinceManager = AppInstalledSinceManager(secureUserSettings: secureUserSettings)
private let cryptoLibUtility = CryptoLibUtility(
	now: now,
	userSettings: userSettings,
	networkManager: networkManager,
	remoteConfigManager: remoteConfigManager,
	reachability: try? Reachability(),
	fileStorage: fileStorage
)
private let clockDeviationManager = ClockDeviationManager(
	remoteConfigManager: remoteConfigManager,
	currentSystemUptime: ClockDeviationManager.currentSystemUptime,
	now: now
)
private let contactInformationProvider = ContactInformationProvider(
	remoteConfigManager: remoteConfigManager
)
private let couplingManager = CouplingManager(cryptoManager: cryptoManager, networkManager: networkManager)
private let userSettings = UserSettings()
private let cryptoManager = CryptoManager(
	cryptoLibUtility: cryptoLibUtility,
	verificationPolicyManager: verificationPolicyManager,
	featureFlagManager: featureFlagManager,
	userSettings: userSettings
)

private let deviceAuthenticationDetector = DeviceAuthenticationDetector()
private let disclosurePolicyManager = DisclosurePolicyManager(
	remoteConfigManager: remoteConfigManager,
	userSettings: userSettings
)

private let fileStorage = FileStorage()
private let identityChecker = IdentityChecker(cryptoManager: cryptoManager)
private let jailBreakDetector = JailBreakDetector()
private let mappingManager = MappingManager(remoteConfigManager: remoteConfigManager)
private let onboardingManager = OnboardingManager(secureUserSettings: secureUserSettings)
private let openIdManager = OpenIDConnectManager()
private let networkManager: NetworkManager = {
	let networkConfiguration: NetworkConfiguration
	   
	   let configurations: [String: NetworkConfiguration] = [
		   NetworkConfiguration.development.name: NetworkConfiguration.development,
		   NetworkConfiguration.test.name: NetworkConfiguration.test,
		   NetworkConfiguration.acceptance.name: NetworkConfiguration.acceptance,
		   NetworkConfiguration.production.name: NetworkConfiguration.production
	   ]
	   
	   let fallbackConfiguration = NetworkConfiguration.development
	   
	   if let networkConfigurationValue = Bundle.main.infoDictionary?["NETWORK_CONFIGURATION"] as? String {
		   networkConfiguration = configurations[networkConfigurationValue] ?? fallbackConfiguration
	   } else {
		   networkConfiguration = fallbackConfiguration
	   }
	   
	   return NetworkManager(configuration: networkConfiguration)
}()
private let newFeaturesManager = NewFeaturesManager(
	secureUserSettings: secureUserSettings
)
private let now: () -> Date = Date.init
private let remoteConfigManager = RemoteConfigManager(
	now: now,
	userSettings: userSettings,
	reachability: try? Reachability(),
	networkManager: networkManager,
	secureUserSettings: secureUserSettings,
	fileStorage: fileStorage
)
private let verificationPolicyManager = VerificationPolicyManager(secureUserSettings: secureUserSettings)
private let scanLockManager = ScanLockManager(now: now, secureUserSettings: secureUserSettings, remoteConfigManager: remoteConfigManager)
private let secureUserSettings = SecureUserSettings()

private let featureFlagManager = FeatureFlagManager(
	remoteConfigManager: remoteConfigManager,
	disclosurePolicyManager: disclosurePolicyManager,
	userSettings: userSettings
)

// MARK: - 3: Instantiate the Environment using private dependencies:

let environment: (DataStoreManager) -> Environment = { datastoreManager in
	
	guard !ProcessInfo().isUnitTesting else {
		fatalError("During unit testing, real services should not be instantiated during Environment setup.")
	}
	
	// Dependencies that depend on `DataStoreManager`:
	let scanLogManager = ScanLogManager(dataStoreManager: datastoreManager, remoteConfigManager: remoteConfigManager, now: now)
	let walletManager = WalletManager(dataStoreManager: datastoreManager)
	let verificationPolicyEnabler = VerificationPolicyEnabler(
		remoteConfigManager: remoteConfigManager,
		userSettings: userSettings,
		verificationPolicyManager: verificationPolicyManager,
		scanLockManager: scanLockManager,
		scanLogManager: scanLogManager
	)
	let greenCardLoader = GreenCardLoader(
		networkManager: networkManager,
		cryptoManager: cryptoManager,
		walletManager: walletManager,
		secureUserSettings: secureUserSettings
	)
	
	return Environment(
		now: now,
		appInstalledSinceManager: appInstalledSinceManager,
		clockDeviationManager: clockDeviationManager,
		contactInformationProvider: contactInformationProvider,
		couplingManager: couplingManager,
		cryptoLibUtility: cryptoLibUtility,
		cryptoManager: cryptoManager,
		dataStoreManager: datastoreManager,
		deviceAuthenticationDetector: deviceAuthenticationDetector,
		disclosurePolicyManager: disclosurePolicyManager,
		featureFlagManager: featureFlagManager,
		greenCardLoader: greenCardLoader,
		identityChecker: identityChecker,
		jailBreakDetector: jailBreakDetector,
		mappingManager: mappingManager,
		networkManager: networkManager,
		newFeaturesManager: newFeaturesManager,
		onboardingManager: onboardingManager,
		openIdManager: openIdManager,
		remoteConfigManager: remoteConfigManager,
		verificationPolicyManager: verificationPolicyManager,
		scanLockManager: scanLockManager,
		scanLogManager: scanLogManager,
		secureUserSettings: secureUserSettings,
		userSettings: userSettings,
		walletManager: walletManager,
		verificationPolicyEnabler: verificationPolicyEnabler
	)
}

// swiftlint:disable identifier_name

var Current: Environment!

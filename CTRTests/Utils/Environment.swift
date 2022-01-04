/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Clcore
@testable import CTR

///
/// Set of Spies with sensible default stubbed values, which can be modified per-test.
///
final class EnvironmentSpies {
	
	fileprivate init() {}
	
	var appInstalledSinceManagerSpy: AppInstalledSinceManagingSpy = {
		let spy = AppInstalledSinceManagingSpy()
		spy.stubbedFirstUseDate = now.addingTimeInterval(31 * days * ago)
		return spy
	}()
	
	var clockDeviationManagerSpy: ClockDeviationManagerSpy = {
		let spy = ClockDeviationManagerSpy()
		spy.stubbedHasSignificantDeviation = false
		spy.stubbedAppendDeviationChangeObserverObserverResult = (false, ())
		spy.stubbedAppendDeviationChangeObserverResult = ClockDeviationManager.ObserverToken()
		
		return spy
	}()
	
	var couplingManagerSpy: CouplingManagerSpy = {
		let spy = CouplingManagerSpy()
		return spy
	}()
	
	var cryptoLibUtilitySpy: CryptoLibUtilitySpy = {
		let spy = CryptoLibUtilitySpy()
		return spy
	}()
	
	var cryptoManagerSpy: CryptoManagerSpy = {
		let spy = CryptoManagerSpy()
		let result = MobilecoreVerificationResult()
		result.status = Int(MobilecoreVERIFICATION_SUCCESS)
		result.details = nil
		spy.stubbedVerifyQRMessageResult = result
		spy.stubbedGenerateQRmessageResult = Data()
		return spy
	}()
	
	var dataStoreManager = DataStoreManager(.inMemory)
	
	var deviceAuthenticationDetectorSpy: DeviceAuthenticationSpy = {
		let spy = DeviceAuthenticationSpy()
		return spy
	}()
	
	var featureFlagManagerSpy: FeatureFlagManagerSpy = {
		let spy = FeatureFlagManagerSpy()
		spy.stubbedIsVerificationPolicyEnabledResult = true
		return spy
	}()
	
	// TODO: should this be on the environment?
	var forcedInformationManagerSpy: ForcedInformationManagerSpy = {
		let spy = ForcedInformationManagerSpy()
		spy.stubbedNeedsUpdating = false
		return spy
	}()
	
	// TODO: should this be on the environment?
	var greenCardLoaderSpy: GreenCardLoaderSpy = {
		let spy = GreenCardLoaderSpy()
		return spy
	}()
	
	var jailBreakDetectorSpy: JailBreakProtocolSpy = {
		let spy = JailBreakProtocolSpy()
		return spy
	}()
	
	var mappingManagerSpy: MappingManagerSpy = {
		let spy = MappingManagerSpy()
		return spy
	}()
	
	var networkManagerSpy: NetworkSpy = {
		let spy = NetworkSpy()
		spy.stubbedGetPublicKeysCompletionResult = (.success(Data()), ())
		return spy
	}()
	
	// TODO: should this be on the environment?
	var onboardingManagerSpy: OnboardingManagerSpy = {
		let spy = OnboardingManagerSpy()
		spy.stubbedNeedsOnboarding = false
		spy.stubbedNeedsConsent = false
		return spy
	}()
	
	var openIdManagerSpy: OpenIdManagerSpy = {
		let spy = OpenIdManagerSpy()
		return spy
	}()
	
	var remoteConfigManagerSpy: RemoteConfigManagingSpy = {
		let spy = RemoteConfigManagingSpy()
		spy.stubbedStoredConfiguration = .default
		spy.stubbedStoredConfiguration.configTTL = 3600
		spy.stubbedStoredConfiguration.configMinimumIntervalSeconds = 60
		spy.stubbedAppendReloadObserverResult = UUID()
		spy.stubbedAppendReloadObserverObserverResult = (.default, Data(), URLResponse())
		spy.stubbedAppendUpdateObserverResult = UUID()
		return spy
	}()
	
	var riskLevelManagerSpy: RiskLevelManagerSpy = {
		let spy = RiskLevelManagerSpy()
		spy.stubbedAppendObserverResult = UUID()
		spy.stubbedState = .high
		return spy
	}()
	
	var scanLockManagerSpy: ScanLockManagerSpy = {
		let spy = ScanLockManagerSpy()
		spy.stubbedState = .unlocked
		spy.stubbedAppendObserverResult = UUID()
		return spy
	}()
	
	var scanLogManagerSpy: ScanLogManagingSpy = {
		let spy = ScanLogManagingSpy()
		spy.stubbedDidWeScanQRsResult = false
		spy.stubbedGetScanEntriesResult = .success([])
		return spy
	}()
	
	var secureUserSettingsSpy: SecureUserSettingsSpy = {
		let spy = SecureUserSettingsSpy()
		spy.stubbedStoredConfiguration = .default
		spy.stubbedForcedInformationData = .empty
		return spy
	}()
	
	var userSettingsSpy: UserSettingsSpy = {
		let spy = UserSettingsSpy()
		spy.stubbedIssuerKeysFetchedTimestamp = now.addingTimeInterval(10 * minutes * ago).timeIntervalSince1970
		spy.stubbedDashboardRegionToggleValue = .domestic
		return spy
	}()
	
	var walletManagerSpy: WalletManagerSpy = {
		let spy = WalletManagerSpy()
		spy.stubbedStoreEventGroupResult = true
		return spy
	}()
}

func setupEnvironmentSpies() -> EnvironmentSpies {
	
	let spies = EnvironmentSpies()
	
	Current = Environment(
		now: { now },
		appInstalledSinceManager: spies.appInstalledSinceManagerSpy,
		clockDeviationManager: spies.clockDeviationManagerSpy,
		couplingManager: spies.couplingManagerSpy,
		cryptoLibUtility: spies.cryptoLibUtilitySpy,
		cryptoManager: spies.cryptoManagerSpy,
		dataStoreManager: DataStoreManager(.inMemory),
		deviceAuthenticationDetector: spies.deviceAuthenticationDetectorSpy,
		featureFlagManager: spies.featureFlagManagerSpy,
		forcedInformationManager: spies.forcedInformationManagerSpy,
		greenCardLoader: spies.greenCardLoaderSpy,
		jailBreakDetector: spies.jailBreakDetectorSpy,
		mappingManager: spies.mappingManagerSpy,
		networkManager: spies.networkManagerSpy,
		onboardingManager: spies.onboardingManagerSpy,
		openIdManager: spies.openIdManagerSpy,
		remoteConfigManager: spies.remoteConfigManagerSpy,
		riskLevelManager: spies.riskLevelManagerSpy,
		scanLockManager: spies.scanLockManagerSpy,
		scanLogManager: spies.scanLogManagerSpy,
		secureUserSettings: spies.secureUserSettingsSpy,
		userSettings: spies.userSettingsSpy,
		walletManager: spies.walletManagerSpy
	)
	
	return spies
}

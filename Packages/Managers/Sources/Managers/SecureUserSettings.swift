/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable redundant_optional_initialization

import Foundation
import Transport
import Shared
import Models

public protocol SecureUserSettingsProtocol: AnyObject {
	typealias ForcedInformationData = NewFeaturesManager.ForcedInformationData
	typealias OnboardingData = OnboardingManager.OnboardingData
	
	var scanLockUntil: Date { get set }
	var appInstalledDate: Date? { get set }
	var forcedInformationData: ForcedInformationData { get set }
	var holderSecretKey: Data? { get set }
	var onboardingData: OnboardingData { get set }
	var selectedIdentity: String? { get set }
	var storedConfiguration: RemoteConfiguration { get set }
	var verificationPolicy: VerificationPolicy? { get set }
	
	func wipePersistedData()
}

public class SecureUserSettings: SecureUserSettingsProtocol {
	
	public struct Defaults {
		public static var scanLockUntil: Date = .distantPast
		public static var appInstalledDate: Date? = nil
		public static var holderSecretKey: Data? = nil
		public static var forcedInformationData: NewFeaturesManager.ForcedInformationData = .empty
		public static var onboardingData: OnboardingManager.OnboardingData = .empty
		public static var selectedIdentity: String? = nil
		public static var storedConfiguration: RemoteConfiguration = .default
		public static var verificationPolicy: VerificationPolicy? = .none
	}
	
	public init() {}
	
	@Keychain(name: "scanLockUntil", service: "ScanLockManager" + Configuration().getEnvironment(), clearOnReinstall: false)
	public var scanLockUntil: Date = Defaults.scanLockUntil
	
	@Keychain(name: "appInstalledDate", service: "AppInstalledSinceManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	public var appInstalledDate: Date? = Defaults.appInstalledDate
	
	@Keychain(name: "data", service: "ForcedInformationManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	public var forcedInformationData: ForcedInformationData = Defaults.forcedInformationData
	
	@Keychain(name: "holderSecretKey", service: "CryptoManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	public var holderSecretKey: Data? = Defaults.holderSecretKey

	@Keychain(name: "onboardingData", service: "OnboardingManager" + Configuration().getEnvironment(), clearOnReinstall: true)
	public var onboardingData: OnboardingData = Defaults.onboardingData

	@Keychain(name: "storedConfiguration", service: "RemoteConfigManager" + Configuration().getEnvironment(), clearOnReinstall: false)
	public var storedConfiguration: RemoteConfiguration = Defaults.storedConfiguration

	@Keychain(name: "verificationPolicy", service: "RiskLevelManager" + Configuration().getEnvironment(), clearOnReinstall: false)
	public var verificationPolicy: VerificationPolicy? = Defaults.verificationPolicy
	
	@Keychain(name: "selectedIdentity", service: "FuzzyMatching" + Configuration().getEnvironment(), clearOnReinstall: false)
	public var selectedIdentity: String? = Defaults.selectedIdentity
}

extension SecureUserSettings {

	public func wipePersistedData() {
		scanLockUntil = Defaults.scanLockUntil
		appInstalledDate = Defaults.appInstalledDate
		forcedInformationData = Defaults.forcedInformationData
		holderSecretKey = Defaults.holderSecretKey
		onboardingData = Defaults.onboardingData
		selectedIdentity = Defaults.selectedIdentity
		storedConfiguration = Defaults.storedConfiguration
		verificationPolicy = Defaults.verificationPolicy
	}
}

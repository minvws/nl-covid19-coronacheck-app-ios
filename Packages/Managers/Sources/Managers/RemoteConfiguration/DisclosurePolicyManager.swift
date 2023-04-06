/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Models
import Resources

public protocol DisclosurePolicyManaging {
	func setDisclosurePolicyUpdateHasBeenSeen()
	func getDisclosurePolicies() -> [String]
	
	var factory: UpdatedDisclosurePolicyFactory { get }
	var observatory: Observatory<Void> { get }
	var hasChanges: Bool { get }
}

public class DisclosurePolicyManager: DisclosurePolicyManaging {
	
	public let factory: UpdatedDisclosurePolicyFactory = UpdatedDisclosurePolicyFactory()
	
	// Mechanism for registering for external state change notifications:
	public let observatory: Observatory<Void>
	private let notifyObservers: (()) -> Void
	
	private var remoteConfigManagerObserverToken: Observatory.ObserverToken?
	private var remoteConfigManager: RemoteConfigManaging
	private let userSettings: UserSettingsProtocol
	
	/// Initiializer
	public init(remoteConfigManager: RemoteConfigManaging, userSettings: UserSettingsProtocol) {
		self.remoteConfigManager = remoteConfigManager
		self.userSettings = userSettings
		(self.observatory, self.notifyObservers) = Observatory<()>.create()
		configureRemoteConfigManager()
	}
	
	deinit {
		remoteConfigManagerObserverToken.map(self.remoteConfigManager.observatoryForUpdates.remove)
	}
	
	private func configureRemoteConfigManager() {
		
		remoteConfigManagerObserverToken = remoteConfigManager.observatoryForUpdates.append { [weak self] _, _, _, _ in
			self?.detectPolicyChange()
		}
	}
		
	public func detectPolicyChange() {
		
		guard hasChanges else {
			return
		}
		
		// Locally stored profile different than the remote ones
		logDebug("DisclosurePolicyManager: policy changed detected")

		// - Update the observers
		notifyObservers(())
	}
	
	public func setDisclosurePolicyUpdateHasBeenSeen() {
		
		let disclosurePolicies = getDisclosurePolicies()
		userSettings.lastKnownConfigDisclosurePolicy = disclosurePolicies
	}
	
	public var hasChanges: Bool {
		
		let disclosurePolicies = getDisclosurePolicies()
		return userSettings.lastKnownConfigDisclosurePolicy != disclosurePolicies
	}
	
	public func getDisclosurePolicies() -> [String] {
		
		guard var disclosurePolicies = remoteConfigManager.storedConfiguration.disclosurePolicies else {
			return []
		}
		
		if userSettings.overrideDisclosurePolicies.isNotEmpty {
			disclosurePolicies = userSettings.overrideDisclosurePolicies
		}
		return disclosurePolicies
	}
}

public struct UpdatedDisclosurePolicyFactory {
	
	/// Generate an array of `PagedAnnoucementItem` for New Disclosure Policy screens
	public static func create(featureFlagManager: FeatureFlagManaging, userSettings: UserSettingsProtocol) -> [PagedAnnoucementItem] {
		
//		let returningFromNoDisclosurePolicies = self.returningFromNoDisclosurePolicies(userSettings: userSettings)
//
//		if featureFlagManager.is1GExclusiveDisclosurePolicyEnabled() {
//
//			return possiblyCombineWithReturnToCTB(
//				PagedAnnoucementItem(
//					title: L.holder_newintheapp_content_only1G_title(),
//					content: L.holder_newintheapp_content_only1G_body(),
//					image: I.disclosurePolicy.newInTheApp(),
//					tagline: L.general_newpolicy(),
//					step: returningFromNoDisclosurePolicies ? 1 : 0,
//					nextButtonTitle: returningFromNoDisclosurePolicies ? L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates() : nil
//				),
//				userSettings: userSettings
//			)
//		} else if featureFlagManager.is3GExclusiveDisclosurePolicyEnabled() {
//
//			return possiblyCombineWithReturnToCTB(
//				PagedAnnoucementItem(
//					title: L.holder_newintheapp_content_only3G_title(),
//					content: L.holder_newintheapp_content_only3G_body(),
//					image: I.disclosurePolicy.newInTheApp(),
//					tagline: L.general_newpolicy(),
//					step: returningFromNoDisclosurePolicies ? 1 : 0,
//					nextButtonTitle: returningFromNoDisclosurePolicies
//						? L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates()
//						: nil
//				),
//				userSettings: userSettings
//			)
//		} else if featureFlagManager.areBothDisclosurePoliciesEnabled() {
//
//			return possiblyCombineWithReturnToCTB(
//				PagedAnnoucementItem(
//					title: L.holder_newintheapp_content_3Gand1G_title(),
//					content: L.holder_newintheapp_content_3Gand1G_body(),
//					image: I.disclosurePolicy.newInTheApp(),
//					tagline: L.general_newpolicy(),
//					step: returningFromNoDisclosurePolicies ? 1 : 0,
//					nextButtonTitle: returningFromNoDisclosurePolicies
//						? L.holder_newintheapp_content_dutchAndInternationalCertificates_button_toMyCertificates()
//						: nil
//				),
//				userSettings: userSettings
//			)
//
//		} else if featureFlagManager.areZeroDisclosurePoliciesEnabled() {
//
//			return [PagedAnnoucementItem(
//				title: L.holder_newintheapp_content_onlyInternationalCertificates_0G_title(),
//				content: L.holder_newintheapp_content_onlyInternationalCertificates_0G_body(),
//				image: I.onboarding.validity(),
//				tagline: L.general_newintheapp(),
//				step: 0
//			)]
//		} else {
//
			return []
//		}
	}
	
	static private func possiblyCombineWithReturnToCTB(_ item: PagedAnnoucementItem, userSettings: UserSettingsProtocol) -> [PagedAnnoucementItem] {
		
		if returningFromNoDisclosurePolicies(userSettings: userSettings) {
			// Special case: 0G -> Any G
			return [reenabledCTBItem, item]
		} else {
			return [item]
		}
	}
	
	static private func returningFromNoDisclosurePolicies(userSettings: UserSettingsProtocol) -> Bool {
		
		return userSettings.lastKnownConfigDisclosurePolicy == [] ||
		userSettings.lastKnownConfigDisclosurePolicy == ["0G"]
	}
	
	static private let reenabledCTBItem: PagedAnnoucementItem = PagedAnnoucementItem(
		title: L.holder_newintheapp_content_dutchAndInternationalCertificates_title(),
		content: L.holder_newintheapp_content_dutchAndInternationalCertificates_body(),
		image: I.disclosurePolicy.dutchAndInternationalQRCards(),
		tagline: L.general_newintheapp(),
		step: 0
	)
}

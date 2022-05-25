/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// the various about menu options
enum AboutThisAppMenuIdentifier: String {

	case accessibility

	case privacyStatement
	
	case colophon

	case reset
	
	case storedEvents
	
	case deeplink

	case scanlog
	
	case useNoDisclosurePolicy
	case use1GDisclosurePolicy
	case use3GDisclosurePolicy
	case use1GAnd3GDisclosurePolicy
	case useConfigDisclosurePolicy
}

///// Struct for information to display the different test providers
struct AboutThisAppMenuOption {

	/// The identifier
	let identifier: AboutThisAppMenuIdentifier

	/// The name
	let name: String
}

class AboutThisAppViewModel: Logging {

	enum Outcome: Equatable {
		case openURL(_: URL, inApp: Bool)
		case userWishesToSeeStoredEvents
		case userWishesToOpenScanLog
		case coordinatorShouldRestart
	}
	
	private let outcomeHandler: (Outcome) -> Void
	private var flavor: AppFlavor

	// MARK: - Bindable

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var appVersion: String
	@Bindable private(set) var configVersion: String?
	@Bindable private(set) var alert: AlertContent?
	@Bindable private(set) var menu: KeyValuePairs<String, [AboutThisAppMenuOption]> = [:]

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - versionSupplier: the version supplier
	///   - flavor: the app flavor
	init(
		versionSupplier: AppVersionSupplierProtocol,
		flavor: AppFlavor,
		outcomeHandler: @escaping (Outcome) -> Void
	) {

		self.outcomeHandler = outcomeHandler
		self.flavor = flavor
		self.title = flavor == .holder ? L.holderAboutTitle() : L.verifierAboutTitle()
		self.message = flavor == .holder ? L.holderAboutText() : L.verifierAboutText()

		appVersion = flavor == .holder
			? L.holderLaunchVersion(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())
			: L.verifierLaunchVersion(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())

		configVersion = {
			guard let timestamp = Current.userSettings.configFetchedTimestamp,
				  let hash = Current.userSettings.configFetchedHash
			else { return nil }

			let dateString = DateFormatter.Format.numericDateWithTime.string(from: Date(timeIntervalSince1970: timestamp))

			return L.generalMenuConfigVersion(String(hash.prefix(7)), dateString)
		}()

		flavor == .holder ? setupMenuHolder() : setupMenuVerifier()
	}
	
	private func setupMenuHolder() {

		var list: [AboutThisAppMenuOption] = [
			AboutThisAppMenuOption(identifier: .privacyStatement, name: L.holderMenuPrivacy()) ,
			AboutThisAppMenuOption(identifier: .accessibility, name: L.holderMenuAccessibility()),
			AboutThisAppMenuOption(identifier: .colophon, name: L.holderMenuColophon()),
			AboutThisAppMenuOption(identifier: .storedEvents, name: L.holder_menu_storedEvents()),
			AboutThisAppMenuOption(identifier: .reset, name: L.holder_menu_resetApp())
		]
		if Configuration().getEnvironment() != "production" {
			list.append(AboutThisAppMenuOption(identifier: .deeplink, name: L.holderMenuVerifierdeeplink()))
		}
		
		let bottomList: [AboutThisAppMenuOption] = [
			AboutThisAppMenuOption(identifier: .useNoDisclosurePolicy, name: "Use no Disclosure policy"),
			AboutThisAppMenuOption(identifier: .use1GDisclosurePolicy, name: "Use 1G Disclosure policy"),
			AboutThisAppMenuOption(identifier: .use3GDisclosurePolicy, name: "Use 3G Disclosure policy"),
			AboutThisAppMenuOption(identifier: .use1GAnd3GDisclosurePolicy, name: "Use 1G and 3G Disclosure policy"),
			AboutThisAppMenuOption(identifier: .useConfigDisclosurePolicy, name: "Use the config Disclosure policy")
		]
		
		if Configuration().getEnvironment() != "production" {
			menu = [
				L.holderAboutReadmore(): list,
				"Disclosure Policy": bottomList
			]
		} else {
			menu = [L.holderAboutReadmore(): list]
		}
	}

	private func setupMenuVerifier() {

		var topList: [AboutThisAppMenuOption] = [
			AboutThisAppMenuOption(identifier: .privacyStatement, name: L.verifierMenuPrivacy()) ,
			AboutThisAppMenuOption(identifier: .accessibility, name: L.verifierMenuAccessibility()),
			AboutThisAppMenuOption(identifier: .colophon, name: L.holderMenuColophon())
		]
		if Configuration().getEnvironment() != "production" {
			topList.append(AboutThisAppMenuOption(identifier: .reset, name: L.holder_menu_resetApp()))
		}
		if Current.featureFlagManager.areMultipleVerificationPoliciesEnabled() {
			menu = [
				L.verifierAboutReadmore(): topList,
				L.verifier_about_this_app_law_enforcement(): [
					AboutThisAppMenuOption(identifier: .scanlog, name: L.verifier_about_this_app_scan_log())
				]
			]
		} else {
			menu = [
				L.verifierAboutReadmore(): topList
			]
		}
	}

	func menuOptionSelected(_ identifier: AboutThisAppMenuIdentifier) {

		switch identifier {
			case .privacyStatement:
				openPrivacyPage()
			case .accessibility:
				openAccessibilityPage()
			case .colophon:
				openUrlString(L.holderUrlColophon())
			case .reset:
				showClearDataAlert()
			case .storedEvents:
				outcomeHandler(.userWishesToSeeStoredEvents)
			case .deeplink:
				openUrlString("https://web.acc.coronacheck.nl/verifier/scan?returnUri=https://web.acc.coronacheck.nl/app/open?returnUri=scanner-test", inApp: false)
			case .scanlog:
				openScanLog()
			case .useNoDisclosurePolicy:
				setDisclosurePolicy(["0G"], message: "New policy: No policy")
			case .use1GDisclosurePolicy:
				setDisclosurePolicy([DisclosurePolicy.policy1G.featureFlag], message: "New policy: 1G")
			case .use3GDisclosurePolicy:
				setDisclosurePolicy([DisclosurePolicy.policy3G.featureFlag], message: "New policy: 3G")
			case .use1GAnd3GDisclosurePolicy:
				setDisclosurePolicy([DisclosurePolicy.policy1G.featureFlag, DisclosurePolicy.policy3G.featureFlag], message: "New policy: 1G + 3G")
			case .useConfigDisclosurePolicy:
				setDisclosurePolicy([], message: "New policy: use the config")
		}
	}

	private func openPrivacyPage() {

		switch flavor {
			case .holder:
				openUrlString(L.holderUrlPrivacy())
			case .verifier:
				openUrlString(L.verifierUrlPrivacy())
		}
	}

	private func openAccessibilityPage() {
		
		switch flavor {
			case .holder:
				openUrlString(L.holderUrlAccessibility())
			case .verifier:
				openUrlString(L.verifierUrlAccessibility())
		}
	}

	private func openUrlString(_ urlString: String, inApp: Bool = true) {

		if let url = URL(string: urlString) {
			outcomeHandler(.openURL(url, inApp: inApp))
		}
	}

	private func showClearDataAlert() {

		alert = AlertContent(
			title: L.holderCleardataAlertTitle(),
			subTitle: L.holderCleardataAlertSubtitle(),
			okAction: AlertContent.Action(
				title: L.holderCleardataAlertRemove(),
				action: { [weak self] _ in
					self?.wipePersistedData()
				},
				actionIsDestructive: true
			),
			cancelAction: AlertContent.Action(title: L.general_cancel())
		)
	}

	func wipePersistedData() {

		Current.wipePersistedData(flavor: flavor)
		outcomeHandler(.coordinatorShouldRestart)
	}

	func openScanLog() {

		outcomeHandler(.userWishesToOpenScanLog)
	}
	
	private func setDisclosurePolicy(_ newPolicy: [String], message: String) {
		
		Current.userSettings.overrideDisclosurePolicies = newPolicy
		Current.userSettings.lastDismissedDisclosurePolicy = []
		
		alert = AlertContent(
			title: "Disclosure policy updated",
			subTitle: message,
			okAction: AlertContent.Action(
				title: L.generalOk(),
				action: { [weak self] _ in
					self?.outcomeHandler(.coordinatorShouldRestart)
				}
			)
		)
	}
}

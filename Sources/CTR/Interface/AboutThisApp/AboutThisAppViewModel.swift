/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
	
	case deeplink

	case scanlog
}

///// Struct for information to display the different test providers
struct AboutThisAppMenuOption {

	/// The identifier
	let identifier: AboutThisAppMenuIdentifier

	/// The name
	let name: String
}

class AboutThisAppViewModel: Logging {

	/// Coordination Delegate
	weak private var coordinator: (OpenUrlProtocol & Restartable)?

	private var flavor: AppFlavor

	private let userSettings: UserSettingsProtocol

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
		coordinator: (OpenUrlProtocol & Restartable),
		versionSupplier: AppVersionSupplierProtocol,
		flavor: AppFlavor,
		userSettings: UserSettingsProtocol) {

		self.coordinator = coordinator
		self.flavor = flavor
		self.userSettings = userSettings

		self.title = flavor == .holder ? L.holderAboutTitle() : L.verifierAboutTitle()
		self.message = flavor == .holder ? L.holderAboutText() : L.verifierAboutText()

		appVersion = flavor == .holder
			? L.holderLaunchVersion(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())
			: L.verifierLaunchVersion(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())

		configVersion = {
			guard let timestamp = userSettings.configFetchedTimestamp,
				  let hash = userSettings.configFetchedHash
			else { return nil }

			// 13-10-2021 00:00
			let dateformatter = DateFormatter()
			dateformatter.dateFormat = "dd-MM-yyyy HH:mm"
			let dateString = dateformatter.string(from: Date(timeIntervalSince1970: timestamp))

			return L.generalMenuConfigVersion(String(hash.prefix(7)), dateString)
		}()

		flavor == .holder ? setupMenuHolder() : setupMenuVerifier()
	}
	private func setupMenuHolder() {

		var list: [AboutThisAppMenuOption] = [
			AboutThisAppMenuOption(identifier: .privacyStatement, name: L.holderMenuPrivacy()) ,
			AboutThisAppMenuOption(identifier: .accessibility, name: L.holderMenuAccessibility()),
			AboutThisAppMenuOption(identifier: .colophon, name: L.holderMenuColophon()),
			AboutThisAppMenuOption(identifier: .reset, name: L.holderCleardataMenuTitle())
		]
		if Configuration().getEnvironment() != "production" {
			list.append(AboutThisAppMenuOption(identifier: .deeplink, name: L.holderMenuVerifierdeeplink()))
		}

		menu = [L.holderAboutReadmore(): list]
	}

	private func setupMenuVerifier() {

		var topList: [AboutThisAppMenuOption] = [
			AboutThisAppMenuOption(identifier: .privacyStatement, name: L.verifierMenuPrivacy()) ,
			AboutThisAppMenuOption(identifier: .accessibility, name: L.verifierMenuAccessibility()),
			AboutThisAppMenuOption(identifier: .colophon, name: L.holderMenuColophon())
		]
		if Configuration().getEnvironment() != "production" {
			topList.append(AboutThisAppMenuOption(identifier: .reset, name: L.holderCleardataMenuTitle()))
		}

		menu = [
			L.verifierAboutReadmore(): topList,
			L.verifier_about_this_app_law_enforcement(): [
				AboutThisAppMenuOption(identifier: .scanlog, name: L.verifier_about_this_app_scan_log())
			]
		]
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
			case .deeplink:
				openUrlString("https://web.acc.coronacheck.nl/verifier/scan?returnUri=https://web.acc.coronacheck.nl/app/open?returnUri=scanner-test", inApp: false)
			case .scanlog:
				openScanLog()
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
			coordinator?.openUrl(url, inApp: inApp)
		}
	}

	private func showClearDataAlert() {

		alert = AlertContent(
			title: L.holderCleardataAlertTitle(),
			subTitle: L.holderCleardataAlertSubtitle(),
			cancelAction: nil,
			cancelTitle: L.generalCancel(),
			okAction: { [weak self] _ in
				self?.resetDataAndRestart()
			},
			okTitle: L.holderCleardataAlertRemove()
		)
	}

	func resetDataAndRestart() {

		Services.reset(flavor: flavor)
		self.userSettings.reset()
		self.coordinator?.restart()
	}

	func openScanLog() {

		if let coordinator = coordinator as? VerifierCoordinatorDelegate {
			coordinator.userWishesToOpenScanLog()
		}
	}
}

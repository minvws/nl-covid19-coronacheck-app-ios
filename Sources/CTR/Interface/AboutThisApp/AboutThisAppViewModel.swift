/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import ReusableViews
import Managers
import Models
import Resources

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

struct AboutThisAppMenuSection {
	
	let title: String?
	let options: [AboutThisAppMenuOption]
}

class AboutThisAppViewModel {

	enum Outcome: Equatable {
		case openURL(_: URL)
		case userWishesToOpenScanLog
		case coordinatorShouldRestart
	}
	
	internal let outcomeHandler: (Outcome) -> Void
	private var flavor: AppFlavor

	// MARK: - Bindable

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var appVersion: String
	@Bindable private(set) var configVersion: String?
	@Bindable private(set) var alert: AlertContent?
	@Bindable private(set) var menu: [AboutThisAppMenuSection] = []

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

		appVersion = L.aboutthisapp_appversion(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())
		
		configVersion = {
			guard let timestamp = Current.userSettings.configFetchedTimestamp,
				  let hash = Current.userSettings.configFetchedHash
			else { return nil }

			let dateString = DateFormatter.Format.numericDateWithTime.string(from: Date(timeIntervalSince1970: timestamp))

			return L.aboutthisapp_configversion(String(hash.prefix(7)), dateString)
		}()

		if flavor == .holder {
			setupMenuHolder()
		} else {
			setupMenuVerifier()
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
				didTapResetApp()
			case .deeplink:
				openUrlString("https://web.acc.coronacheck.nl/verifier/scan?returnUri=https://web.acc.coronacheck.nl/app/open?returnUri=scanner-test")
			case .scanlog:
				openScanLog()
		}
	}
	
	func didTapResetApp() {
		showClearDataAlert()
	}
	
	private func setupMenuHolder() {

		var list: [AboutThisAppMenuOption] = [
			AboutThisAppMenuOption(identifier: .privacyStatement, name: L.holderMenuPrivacy()),
			AboutThisAppMenuOption(identifier: .accessibility, name: L.holderMenuAccessibility()),
			AboutThisAppMenuOption(identifier: .colophon, name: L.holderMenuColophon())
		]
		if Configuration().getRelease() != .production {
			list.append(AboutThisAppMenuOption(identifier: .deeplink, name: L.holderMenuVerifierdeeplink()))
		}
		
		menu = [AboutThisAppMenuSection(title: nil, options: list)]
	}

	private func setupMenuVerifier() {

		let list: [AboutThisAppMenuOption] = [
			AboutThisAppMenuOption(identifier: .privacyStatement, name: L.verifierMenuPrivacy()),
			AboutThisAppMenuOption(identifier: .accessibility, name: L.verifierMenuAccessibility()),
			AboutThisAppMenuOption(identifier: .colophon, name: L.holderMenuColophon())
		]
		if Current.featureFlagManager.areMultipleVerificationPoliciesEnabled() {
			menu = [
				AboutThisAppMenuSection(title: nil, options: list),
				AboutThisAppMenuSection(title: L.verifier_about_this_app_law_enforcement(), options: [
					AboutThisAppMenuOption(identifier: .scanlog, name: L.verifier_about_this_app_scan_log())
				])
			]
		} else {
			menu = [
				AboutThisAppMenuSection(title: nil, options: list)
			]
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

	private func openUrlString(_ urlString: String) {

		if let url = URL(string: urlString) {
			outcomeHandler(.openURL(url))
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
				isDestructive: true
			),
			cancelAction: AlertContent.Action.cancel
		)
	}

	private func wipePersistedData() {

		Current.wipePersistedData(flavor: flavor)
		outcomeHandler(.coordinatorShouldRestart)
	}

	private func openScanLog() {

		outcomeHandler(.userWishesToOpenScanLog)
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// the various about menu options
enum AboutMenuIdentifier: String {

	case accessibility

	case privacyStatement

	case terms
	
	case colophon

	case clearData
	
	case deeplink
}

///// Struct for information to display the different test providers
struct AboutMenuOption {

	/// The identifier
	let identifier: AboutMenuIdentifier

	/// The name
	let name: String
}

class AboutViewModel: Logging {

	/// Coordination Delegate
	weak private var coordinator: OpenUrlProtocol?

	private var flavor: AppFlavor

	private weak var walletManager: WalletManaging? = Services.walletManager

	private weak var remoteConfigManager: RemoteConfigManaging? = Services.remoteConfigManager

	private weak var cryptoLibUtility: CryptoLibUtilityProtocol? = Services.cryptoLibUtility

	private let userSettings: UserSettingsProtocol

	// MARK: - Bindable

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var appVersion: String
	@Bindable private(set) var configVersion: String?
	@Bindable private(set) var listHeader: String
	@Bindable private(set) var alert: AlertContent?
	@Bindable private(set) var menu: [AboutMenuOption] = []

	// MARK: - Initializer

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - versionSupplier: the version supplier
	///   - flavor: the app flavor
	init(
		coordinator: OpenUrlProtocol,
		versionSupplier: AppVersionSupplierProtocol,
		flavor: AppFlavor,
		userSettings: UserSettingsProtocol) {

		self.coordinator = coordinator
		self.flavor = flavor
		self.userSettings = userSettings

		self.title = flavor == .holder ? L.holderAboutTitle() : L.verifierAboutTitle()
		self.message = flavor == .holder ? L.holderAboutText() : L.verifierAboutText()
		self.listHeader = flavor == .holder ? L.holderAboutReadmore() : L.verifierAboutReadmore()

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

		menu = [
			AboutMenuOption(identifier: .privacyStatement, name: L.holderMenuPrivacy()) ,
			AboutMenuOption(identifier: .accessibility, name: L.holderMenuAccessibility()),
			AboutMenuOption(identifier: .colophon, name: L.holderMenuColophon())
		]
		if Configuration().getEnvironment() != "production" {
			menu.append(AboutMenuOption(identifier: .clearData, name: L.holderCleardataMenuTitle()))
			menu.append(AboutMenuOption(identifier: .deeplink, name: L.holderMenuVerifierdeeplink()))
		}
	}

	private func setupMenuVerifier() {

		menu = [
			AboutMenuOption(identifier: .terms, name: L.verifierMenuPrivacy()) ,
			AboutMenuOption(identifier: .accessibility, name: L.verifierMenuAccessibility()),
			AboutMenuOption(identifier: .colophon, name: L.holderMenuColophon())
		]
	}

	func menuOptionSelected(_ identifier: AboutMenuIdentifier) {

		switch identifier {
			case .privacyStatement:
				openUrlString(L.holderUrlPrivacy())
			case .terms:
				openUrlString(L.verifierUrlPrivacy())
			case .accessibility:
				if flavor == .holder {
					openUrlString(L.holderUrlAccessibility())
				} else {
					openUrlString(L.verifierUrlAccessibility())
				}
			case .colophon:
				openUrlString(L.holderUrlColophon())
			case .clearData:
				showClearDataAlert()
			case .deeplink:
				openUrlString("https://web.acc.coronacheck.nl/verifier/scan?returnUri=https://web.acc.coronacheck.nl/app/open?returnUri=scanner-test", inApp: false)
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
			okAction: { _ in
				self.clearData()
			},
			okTitle: L.holderCleardataAlertRemove()
		)
	}

	func clearData() {
		
		// Reset all the data
		walletManager?.removeExistingEventGroups()
		walletManager?.removeExistingGreenCards()
		remoteConfigManager?.reset()
		cryptoLibUtility?.reset()
		userSettings.reset()
	}
}

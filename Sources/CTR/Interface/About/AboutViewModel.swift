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

	weak var walletManager: WalletManaging? = Services.walletManager

	// MARK: - Bindable

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var version: String
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
		flavor: AppFlavor) {

		self.coordinator = coordinator
		self.flavor = flavor

		self.title = flavor == .holder ? L.holderAboutTitle() : L.verifierAboutTitle()
		self.message = flavor == .holder ? L.holderAboutText() : L.verifierAboutText()
		self.listHeader = flavor == .holder ? L.holderAboutReadmore() : L.verifierAboutReadmore()

		version = flavor == .holder
			? L.holderLaunchVersion(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())
			: L.verifierLaunchVersion(versionSupplier.getCurrentVersion(), versionSupplier.getCurrentBuild())

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
		}
	}

	private func openUrlString(_ urlString: String) {

		if let url = URL(string: urlString) {
			coordinator?.openUrl(url, inApp: true)
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
			}, okTitle: L.holderCleardataAlertRemove()
		)
	}

	func clearData() {

		walletManager?.removeExistingEventGroups()
		walletManager?.removeExistingGreenCards()
	}
}

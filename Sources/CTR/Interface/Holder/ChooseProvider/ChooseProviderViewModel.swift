/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum ProviderIdentifier: String {

	case ggd
	case commercial
}

struct Provider {

	let identifier: ProviderIdentifier
	let name: String
	let subTitle: String
}

class ChooseProviderViewModel: Logging {

	var loggingCategory: String = "ChooseProviderViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The open id client
	weak var openIdManager: OpenIdManaging?

	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var title: String
	@Bindable private(set) var subtitle: String
	@Bindable private(set) var body: String
	@Bindable private(set) var providers: [Provider]
	@Bindable private(set) var showProgress: Bool

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(
		coordinator: HolderCoordinatorDelegate,
		proofManager: ProofManaging,
		openIdManager: OpenIdManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		self.openIdManager = openIdManager
		title = .holderChooseProviderTitle
		subtitle = .holderChooseProviderSubtitle
		body = .holderChooseProviderMessage
		image = .createBig
		providers = [
			Provider(
				identifier: .commercial,
				name: .holderChooseProviderCommercialTitle,
				subTitle: .holderChooseProviderCommercialSubtitle
			),
			Provider(
				identifier: .ggd,
				name: .holderChooseProviderGGDTitle,
				subTitle: .holderChooseProviderGGDSubtitle
			)
		]
		showProgress = false
	}

	/// The user selected a provider
	/// - Parameters:
	///   - identifier: the identifier of the provider
	///   - presentingViewController: The presenting viewcontroller
	func providerSelected(
		_ identifier: ProviderIdentifier,
		presentingViewController: UIViewController?) {

		logInfo("Selected \(identifier)")

		if identifier == ProviderIdentifier.commercial {
			loginCommercial()
		} else if identifier == ProviderIdentifier.ggd {
			loginGGD(presentingViewController)
		}
	}

	func loginCommercial() {

		showProgress = true

		proofManager?.fetchTestResult("1234") { [weak self] error in
			self?.showProgress = false

			if let error = error {
				self?.logDebug("Error: \(error.localizedDescription)")
			} else {
				self?.coordinator?.navigateToListResults()
			}
		}
	}

	/// Login at the GGD
	/// - Parameter presentingViewController: the presenting viewcontroller
	func loginGGD(_ presentingViewController: UIViewController?) {

		guard let viewController = presentingViewController else {
			self.logError("Can't present login for GGD")
			return
		}

		openIdManager?.requestAccessToken(
			presenter: viewController) { [weak self] accessToken in
			self?.logDebug("Got Acces token: \(accessToken ?? "nil") ")

			// Can't deal with token just yet.
//			if let token = accessToken {
//				self?.getTestResults(token)
//			}
			// For now, reset test results
			self?.proofManager?.removeTestWrapper()
			self?.coordinator?.navigateToListResults()

		} onError: { [weak self] error in
			self?.logError("Authorization error: \(error?.localizedDescription ?? "Unknown error")")

		}
	}
}

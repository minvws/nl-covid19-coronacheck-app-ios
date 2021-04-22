/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The identity of a provider
enum ProviderIdentifier: String {

	// A Commercial Test Provider
	case commercial

	/// The GGD
	case ggd
}

/// Struct for information to display the different test providers
struct DisplayProvider {

	/// The identifier
	let identifier: ProviderIdentifier

	/// The name
	let name: String

	/// The subtitle
	let subTitle: String?
}

extension DisplayProvider {

	static var commercialDisplayProvider: DisplayProvider {
		return DisplayProvider(
			identifier: .commercial,
			name: .holderChooseProviderCommercialTitle,
			subTitle: nil
		)
	}

	static var ggdDisplayProvider: DisplayProvider {
		return DisplayProvider(
			identifier: .ggd,
			name: .holderChooseProviderGGDTitle,
			subTitle: .holderChooseProviderGGDSubtitle
		)
	}
}

class ChooseProviderViewModel: Logging {

	/// The logging category
	var loggingCategory: String = "ChooseProviderViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The open id client
	weak var openIdManager: OpenIdManaging?

	/// The header image
	@Bindable private(set) var image: UIImage?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The sub title of the scene (differs from the page title)
	@Bindable private(set) var header: String

	/// The information body of the scene
	@Bindable private(set) var body: String

	/// The Test Provider options
	@Bindable private(set) var providers: [DisplayProvider] = []

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - openIdManager: the open ID manager (for GGD)
	///   - enableGGD: True if we want to enable the GGD option
	init(
		coordinator: HolderCoordinatorDelegate,
		openIdManager: OpenIdManaging,
		enableGGD: Bool = false) {

		self.coordinator = coordinator
		self.openIdManager = openIdManager
		title = .holderChooseProviderTitle
		header = .holderChooseProviderHeader
		body = .holderChooseProviderMessage
		image = .create
		setupProviders(includeGGD: enableGGD)
	}

	private func setupProviders(includeGGD: Bool) {

		// use internal var to prevent updating the @binding providers too often
		var providerList = [DisplayProvider]()
		providerList.append(DisplayProvider.commercialDisplayProvider)
		if includeGGD {
			providerList.append(DisplayProvider.ggdDisplayProvider)
		}

		providers = providerList
	}

	/// The user selected a provider
	/// - Parameters:
	///   - identifier: the identifier of the provider
	///   - presentingViewController: The presenting view controller
	func providerSelected(
		_ identifier: ProviderIdentifier,
		presentingViewController: UIViewController?) {

		logInfo("Provider selected: \(identifier)")

		if identifier == ProviderIdentifier.commercial {
			loginCommercial()
		} else if identifier == ProviderIdentifier.ggd {
			loginGGD(presentingViewController)
		}
	}

	/// Login at a commercial tester
	private func loginCommercial() {

		coordinator?.navigateToTokenOverview()
	}

	/// Login at the GGD
	/// - Parameter presentingViewController: the presenting view controller
	private func loginGGD(_ presentingViewController: UIViewController?) {

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

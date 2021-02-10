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

	weak var proofManager: ProofManaging?

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
	init(coordinator: HolderCoordinatorDelegate, proofManager: ProofManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		title = .holderChooseProviderTitle
		subtitle = .holderChooseProviderSubtitle
		body = .holderChooseProviderMessage
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
	/// - Parameter identifier: the identifier of the provider
	func providerSelected(_ identifier: ProviderIdentifier) {

		logInfo("Selected \(identifier)")

		if identifier == ProviderIdentifier.commercial {

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
	}
}

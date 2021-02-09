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

	@Bindable private(set) var image: UIImage?
	@Bindable private(set) var title: String
	@Bindable private(set) var subtitle: String
	@Bindable private(set) var body: String
	@Bindable private(set) var providers: [Provider]

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - userIdentifier: the user identifier
	init(
		coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator
		title = .holderChooseProviderTitle
		subtitle = .holderChooseProviderSubtitle
		body = .holderChooseProviderMessage
		providers = [
			Provider(
				identifier: .ggd,
				name: .holderChooseProviderGGDTitle,
				subTitle: .holderChooseProviderGGDSubtitle
			),
			Provider(
				identifier: .commercial,
				name: .holderChooseProviderCommercialTitle,
				subTitle: .holderChooseProviderCommercialSubtitle
			)
		]
	}

	/// The user selected a provider
	/// - Parameter identifier: the identifier of the provider
	func providerSelected(_ identifier: ProviderIdentifier) {

		logInfo("Selected \(identifier)")
	}
}

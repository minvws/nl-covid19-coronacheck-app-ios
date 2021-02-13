/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// The identty of a provider
enum TokenIdentifier: String {

	// A code
	case code

	/// QR
	case qr
}

/// Struct for information to display the different test providers
struct TokenProvider {

	/// The identifer
	let identifier: TokenIdentifier

	/// The name
	let name: String

	/// The subtite
	let subTitle: String
}

class TokenOverviewViewModel: Logging {

	var loggingCategory: String = "TokenOverviewViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The message of the scene
	@Bindable private(set) var message: String

	/// The token providers
	@Bindable private(set) var providers: [TokenProvider]

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator

		title = .holderTokenOverviewTitle
		message = .holderTokenOverviewText
		providers = [
			TokenProvider(
				identifier: .code,
				name: .holderTokenOverviewCodeTitle,
				subTitle: .holderTokenOverviewCodeText
			),
			TokenProvider(
				identifier: .qr,
				name: .holderTokenOverviewQRTitle,
				subTitle: .holderTokenOverviewQRText
			)
		]
	}

	/// The user selected a provider
	/// - Parameters:
	///   - identifier: the identifier of the provider
	func providerSelected(_ identifier: TokenIdentifier) {

		logInfo("Provider selected: \(identifier)")

		if identifier == TokenIdentifier.code {
			coordinator?.navigateToTokenEntry(nil)
		} else if identifier == TokenIdentifier.qr {
			// Todo, create scanner and parse code.
			coordinator?.navigateToTokenScan()
		}
	}

	/// The user has no code
	func noCode() {

		logInfo("Provider selected: no code")
		coordinator?.presentInformationPage(title: .holderTokenOverviewNoCode, body: .holderTokenOverviewNoCodeDetails)
	}
}

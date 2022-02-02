/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PaperProofInputCouplingCodeViewModel {

	enum Config {
		static let requiredTokenLength = 6
		static let permittedCharacterSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567")
	}

	// MARK: - Bindable Strings

	@Bindable private(set) var title = L.holderDcctokenentryTitle()
	@Bindable private(set) var header = L.holderDcctokenentryHeader()
	@Bindable private(set) var tokenEntryFieldTitle = L.holderDcctokenentryTokenFieldTitle()
	@Bindable private(set) var tokenEntryFieldPlaceholder = { () -> String in
		if UIAccessibility.isVoiceOverRunning {
			return L.holderDcctokenentryTokenFieldPlaceholderScreenreader()
		} else {
			return L.holderDcctokenentryTokenFieldPlaceholder()
		}
	}()
	@Bindable private(set) var nextButtonTitle = L.holderDcctokenentryNext()
	@Bindable private(set) var fieldErrorMessage: String?
	@Bindable private(set) var userNeedsATokenButtonTitle = L.holderDcctokenentryButtonNotoken()

	// MARK: - Private Dependencies:

	private weak var coordinator: PaperProofCoordinatorDelegate?

	// MARK: - Private vars

	private var userTokenInput: String?

	// MARK: - Initializer

	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	///   - requestToken: an optional existing request token
	init(coordinator: PaperProofCoordinatorDelegate) {

		self.coordinator = coordinator
	}

	// MARK: Handling user input

	/// Is this user input permitted to be entered?
	func validateInput(input: String?) -> Bool {
		guard let input = input else { return true }
		let correctAlphabet = input.unicodeScalars.allSatisfy({ Config.permittedCharacterSet.contains($0) })
		let correctLength = input.count <= Config.requiredTokenLength

		return correctLength && correctAlphabet
	}

	func userDidUpdateTokenField(rawTokenInput: String?) {
		fieldErrorMessage = nil
		userTokenInput = rawTokenInput
	}

	/// User tapped the next button
	/// - Parameters:
	///   - tokenInput: the token input
	///   - verificationInput: the verification input
	func nextButtonTapped() {
		fieldErrorMessage = nil

		guard
			// Strip whitespace
			let sanitizedInput = userTokenInput
				.map({ $0.strippingWhitespace() })?
				.uppercased(),
				sanitizedInput.isNotEmpty()
				
		else {
			fieldErrorMessage = L.holderDcctokenentryErrorEmptycode()
			return
		}

		guard
			// Does input consist of permitted alphabet?
			sanitizedInput.unicodeScalars.allSatisfy({ Config.permittedCharacterSet.contains($0) }),
			// Required length
			sanitizedInput.count == Config.requiredTokenLength

		else {
			fieldErrorMessage = L.holderDcctokenentryErrorInvalidcode()
			return
		}

		coordinator?.userDidSubmitPaperProofToken(token: sanitizedInput)
	}

	func userHasNoTokenButtonTapped() {

		coordinator?.userWishesMoreInformationOnNoInputToken()
	}
}

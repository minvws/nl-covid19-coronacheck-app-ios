/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

/// Mechanism for dynamically retrieving Strings depending on the `InitializationMode`:
extension TokenEntryViewModel {
	
	struct Strings {
		
		static func title(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowTitle()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowTitle()
				case (_, .visitorPass):
					return L.visitorpass_code_title()
			}
		}

		static func text(forMode initializationMode: InitializationMode, inputMode: InputMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String? {
			switch (initializationMode, inputMode, retrievalMode) {
					
				case (_, .none, _):
					return nil
				case (.regular, _, .negativeTest):
					return L.holderTokenentryRegularflowText()
				case (.withRequestTokenProvided, _, .negativeTest):
					return L.holderTokenentryUniversallinkflowText()
				case (.regular, _, .visitorPass):
					return L.visitorpass_code_description()
				case (.withRequestTokenProvided, _, .visitorPass):
					return L.visitorpass_code_description_deeplink()
			}
		}
		
		// Secondary button: No token
		static func notokenButtonTitle(forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch retrievalMode {
				case .negativeTest:
					return L.holderTokenentryButtonNotoken()
				case .visitorPass:
					return L.visitorpass_code_review_button()
			}
		}
		
		// Secondary button: No verification code
		static func resendVerificationButtonTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest), (_, .visitorPass):
					return L.holderTokenentryRegularflowRetryTitle()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowRetryTitle()
			}
		}
		
		static func errorInvalidCode(forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch retrievalMode {
				case .negativeTest:
					return L.holderTokenentryRegularflowErrorInvalidCode()
				case .visitorPass:
					return L.visitorpass_token_error_invalid_code()
			}
		}
		
		static func errorInvalidCombination(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (_, .negativeTest):
					return L.holderTokenentryRegularflowErrorInvalidCombination()
				case (_, .visitorPass):
					return L.visitorpass_token_error_invalid_combination()
			}
		}
		
		static func tokenIsEmpty(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowErrorEmptytoken()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowErrorEmptytoken()
				case (_, .visitorPass):
					return L.visitorpass_token_error_empty_token()
			}
		}
		
		static func codeIsEmpty(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest), (_, .visitorPass):
					return L.holderTokenentryRegularflowErrorEmptycode()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowErrorEmptycode()
			}
		}
		
		static func unknownProvider(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowErrorUnknownprovider()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowErrorUnknownprovider()
				case (_, .visitorPass):
					return L.visitorpass_token_error_unknown_provider()
			}
		}
		
		static func tokenEntryHeaderTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowTokenTitle()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowTokenTitle()
				case (_, .visitorPass):
					return L.visitorpass_code_review_input()
			}
		}
		
		static func tokenEntryPlaceholder(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					if UIAccessibility.isVoiceOverRunning {
						return L.holderTokenentryRegularflowTokenPlaceholderScreenreader()
					} else {
						return L.holderTokenentryRegularflowTokenPlaceholder()
					}
				case (.withRequestTokenProvided, .negativeTest):
					if UIAccessibility.isVoiceOverRunning {
						return L.holderTokenentryUniversallinkflowTokenPlaceholderScreenreader()
					} else {
						return L.holderTokenentryUniversallinkflowTokenPlaceholder()
					}
				case (_, .visitorPass):
					if UIAccessibility.isVoiceOverRunning {
						return L.visitorpass_code_review_placeholder_screenreader()
					} else {
						return L.visitorpass_code_review_placeholder()
					}
			}
		}
		
		static func verificationEntryHeaderTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest), (_, .visitorPass):
					return L.holderTokenentryRegularflowVerificationTitle()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowVerificationTitle()
			}
		}
		
		static func verificationInfo(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest), (_, .visitorPass):
					return L.holderTokenentryRegularflowVerificationInfo()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowVerificationInfo()
			}
		}
		
		static func verificationPlaceholder(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest), (_, .visitorPass):
					return L.holderTokenentryRegularflowVerificationPlaceholder()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowVerificationPlaceholder()
			}
		}
		
		static func primaryTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowNext()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowNext()
				case (_, .visitorPass):
					return L.visitorpass_token_next()
			}
		}
		
		// SMS Resend Verification Alert
		
		static func confirmResendVerificationAlertTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest), (_, .visitorPass):
					return L.holderTokenentryRegularflowConfirmresendverificationalertTitle()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertTitle()
			}
		}
		
		static func confirmResendVerificationAlertMessage(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest), (_, .visitorPass):
					return L.holderTokenentryRegularflowConfirmresendverificationalertMessage()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertMessage()
			}
		}
		
		static func confirmResendVerificationAlertOkayButton(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest), (_, .visitorPass):
					return L.holderTokenentryRegularflowConfirmresendverificationalertOkaybutton()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertOkaybutton()
			}
		}
		
		static func confirmResendVerificationAlertCancelButton(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest), (_, .visitorPass):
					return L.holderTokenentryRegularflowConfirmresendverificationalertCancelbutton()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertCancelbutton()
			}
		}
	}
}

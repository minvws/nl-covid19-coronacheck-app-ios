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
					return L.visitorpass_tokenentry_title()
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
				case (_, _, .visitorPass):
					return L.visitorpass_tokenentry_text()
			}
		}
		
		// Secondary button: No token
		static func notokenButtonTitle(forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch retrievalMode {
				case .negativeTest:
					return L.holderTokenentryButtonNotoken()
				case .visitorPass:
					return L.visitorpass_tokenentry_button_notoken()
			}
		}
		
		// Secondary button: No verification code
		static func resendVerificationButtonTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowRetryTitle()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowRetryTitle()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_verification_notoken()
			}
		}
		
		static func errorInvalidCode(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowErrorInvalidCode()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowErrorInvalidCode()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_error_invalidCode()
			}
		}
		
		static func errorInvalidCombination(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowErrorInvalidCombination()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowErrorInvalidCombination()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_error_invalid_combination()
			}
		}
		
		static func tokenIsEmpty(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowErrorEmptytoken()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowErrorEmptytoken()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_error_empty_token()
			}
		}
		
		static func codeIsEmpty(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowErrorEmptycode()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowErrorEmptycode()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_error_empty_code()
			}
		}
		
		static func unknownProvider(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowErrorUnknownprovider()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowErrorUnknownprovider()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_error_unknown_provider()
			}
		}
		
		static func tokenEntryHeaderTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowTokenTitle()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowTokenTitle()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_token_title()
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
						return L.visitorpass_tokenentry_token_placeholder_screenreader()
					} else {
						return L.visitorpass_tokenentry_token_placeholder()
					}
			}
		}
		
		static func verificationEntryHeaderTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowVerificationTitle()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowVerificationTitle()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_verification_title()
			}
		}
		
		static func verificationInfo(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowVerificationInfo()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowVerificationInfo()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_verification_info()
			}
		}
		
		static func verificationPlaceholder(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowVerificationPlaceholder()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowVerificationPlaceholder()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_verification_placeholder()
			}
		}
		
		static func primaryTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowNext()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowNext()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_next()
			}
		}
		
		// SMS Resend Verification Alert
		
		static func confirmResendVerificationAlertTitle(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowConfirmresendverificationalertTitle()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertTitle()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_confirmresendverificationalert_title()
			}
		}
		
		static func confirmResendVerificationAlertMessage(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowConfirmresendverificationalertMessage()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertMessage()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_confirmresendverificationalert_message()
			}
		}
		
		static func confirmResendVerificationAlertOkayButton(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowConfirmresendverificationalertOkaybutton()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertOkaybutton()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_confirmresendverificationalert_okbutton()
			}
		}
		
		static func confirmResendVerificationAlertCancelButton(forMode mode: InitializationMode, forInputRetrievalCodeMode retrievalMode: InputRetrievalCodeMode) -> String {
			switch (mode, retrievalMode) {
				case (.regular, .negativeTest):
					return L.holderTokenentryRegularflowConfirmresendverificationalertCancelbutton()
				case (.withRequestTokenProvided, .negativeTest):
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertCancelbutton()
				case (_, .visitorPass):
					return L.visitorpass_tokenentry_confirmresendverificationalert_cancelbutton()
			}
		}
	}
}

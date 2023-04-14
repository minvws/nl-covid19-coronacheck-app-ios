/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import Resources

/// Mechanism for dynamically retrieving Strings depending on the `InitializationMode`:
extension InputRetrievalCodeViewModel {
	
	struct Strings {
		
		static func title(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowTitle()
			}
		}

		static func text(forMode initializationMode: InitializationMode, inputMode: InputMode) -> String? {
			switch (initializationMode, inputMode) {
				case (_, .none):
					return nil
				case (.regular, _):
					return L.holderTokenentryRegularflowText()
				case (.withRequestTokenProvided, _):
					return L.holderTokenentryUniversallinkflowText()
			}
		}
		
		// Secondary button: No token
		static func notokenButtonTitle() -> String {
			return L.holderTokenentryButtonNotoken()
		}
		
		// Secondary button: No verification code
		static func resendVerificationButtonTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowRetryTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowRetryTitle()
			}
		}
		
		static func errorInvalidCode() -> String {
			return L.holderTokenentryRegularflowErrorInvalidCode()
		}
		
		static func errorInvalidCombination() -> String {
			return L.holderTokenentryRegularflowErrorInvalidCombination()
		}
		
		static func tokenIsEmpty(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowErrorEmptytoken()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowErrorEmptytoken()
			}
		}
		
		static func codeIsEmpty(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowErrorEmptycode()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowErrorEmptycode()
			}
		}
		
		static func unknownProvider(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowErrorUnknownprovider()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowErrorUnknownprovider()
			}
		}
		
		static func tokenEntryHeaderTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowTokenTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowTokenTitle()
			}
		}
		
		static func tokenEntryPlaceholder(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					if UIAccessibility.isVoiceOverRunning {
						return L.holderTokenentryRegularflowTokenPlaceholderScreenreader()
					} else {
						return L.holderTokenentryRegularflowTokenPlaceholder()
					}
				case .withRequestTokenProvided:
					if UIAccessibility.isVoiceOverRunning {
						return L.holderTokenentryUniversallinkflowTokenPlaceholderScreenreader()
					} else {
						return L.holderTokenentryUniversallinkflowTokenPlaceholder()
					}
			}
		}
		
		static func verificationEntryHeaderTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowVerificationTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowVerificationTitle()
			}
		}
		
		static func verificationInfo(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowVerificationInfo()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowVerificationInfo()
			}
		}
		
		static func verificationPlaceholder(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowVerificationPlaceholder()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowVerificationPlaceholder()
			}
		}
		
		static func primaryTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowNext()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowNext()
			}
		}
		
		// SMS Resend Verification Alert
		
		static func confirmResendVerificationAlertTitle(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowConfirmresendverificationalertTitle()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertTitle()
			}
		}
		
		static func confirmResendVerificationAlertMessage(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowConfirmresendverificationalertMessage()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertMessage()
			}
		}
		
		static func confirmResendVerificationAlertOkayButton(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowConfirmresendverificationalertOkaybutton()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertOkaybutton()
			}
		}
		
		static func confirmResendVerificationAlertCancelButton(forMode mode: InitializationMode) -> String {
			switch mode {
				case .regular:
					return L.holderTokenentryRegularflowConfirmresendverificationalertCancelbutton()
				case .withRequestTokenProvided:
					return L.holderTokenentryUniversallinkflowConfirmresendverificationalertCancelbutton()
			}
		}
	}
}

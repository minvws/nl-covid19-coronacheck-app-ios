//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
@testable import CTR

class TokenEntryViewModelSpy: TokenEntryViewModel {

    var invokedTokenGetter = false
    var invokedTokenGetterCount = 0
    var stubbedToken: String!

    override var token: String? {
        invokedTokenGetter = true
        invokedTokenGetterCount += 1
        return stubbedToken
    }

    var invokedShowProgressGetter = false
    var invokedShowProgressGetterCount = 0
    var stubbedShowProgress: Bool! = false

    override var showProgress: Bool {
        invokedShowProgressGetter = true
        invokedShowProgressGetterCount += 1
        return stubbedShowProgress
    }

    var invokedShowVerificationGetter = false
    var invokedShowVerificationGetterCount = 0
    var stubbedShowVerification: Bool! = false

    override var showVerification: Bool {
        invokedShowVerificationGetter = true
        invokedShowVerificationGetterCount += 1
        return stubbedShowVerification
    }

    var invokedEnableNextButtonGetter = false
    var invokedEnableNextButtonGetterCount = 0
    var stubbedEnableNextButton: Bool! = false

    override var enableNextButton: Bool {
        invokedEnableNextButtonGetter = true
        invokedEnableNextButtonGetterCount += 1
        return stubbedEnableNextButton
    }

    var invokedErrorMessageGetter = false
    var invokedErrorMessageGetterCount = 0
    var stubbedErrorMessage: String!

    override var errorMessage: String? {
        invokedErrorMessageGetter = true
        invokedErrorMessageGetterCount += 1
        return stubbedErrorMessage
    }

    var invokedSecondaryButtonTitleGetter = false
    var invokedSecondaryButtonTitleGetterCount = 0
    var stubbedSecondaryButtonTitle: String!

    override var secondaryButtonTitle: String? {
        invokedSecondaryButtonTitleGetter = true
        invokedSecondaryButtonTitleGetterCount += 1
        return stubbedSecondaryButtonTitle
    }

    var invokedSecondaryButtonEnabledGetter = false
    var invokedSecondaryButtonEnabledGetterCount = 0
    var stubbedSecondaryButtonEnabled: Bool! = false

    override var secondaryButtonEnabled: Bool {
        invokedSecondaryButtonEnabledGetter = true
        invokedSecondaryButtonEnabledGetterCount += 1
        return stubbedSecondaryButtonEnabled
    }

    var invokedShowErrorGetter = false
    var invokedShowErrorGetterCount = 0
    var stubbedShowError: Bool! = false

    override var showError: Bool {
        invokedShowErrorGetter = true
        invokedShowErrorGetterCount += 1
        return stubbedShowError
    }

    var invokedHandleInput = false
    var invokedHandleInputCount = 0
    var invokedHandleInputParameters: (tokenInput: String?, verificationInput: String?)?
    var invokedHandleInputParametersList = [(tokenInput: String?, verificationInput: String?)]()

    override func handleInput(_ tokenInput: String?, verificationInput: String?) {
        invokedHandleInput = true
        invokedHandleInputCount += 1
        invokedHandleInputParameters = (tokenInput, verificationInput)
        invokedHandleInputParametersList.append((tokenInput, verificationInput))
    }

    var invokedNextButtonPressed = false
    var invokedNextButtonPressedCount = 0
    var invokedNextButtonPressedParameters: (tokenInput: String?, verificationInput: String?)?
    var invokedNextButtonPressedParametersList = [(tokenInput: String?, verificationInput: String?)]()

    override func nextButtonPressed(_ tokenInput: String?, verificationInput: String?) {
        invokedNextButtonPressed = true
        invokedNextButtonPressedCount += 1
        invokedNextButtonPressedParameters = (tokenInput, verificationInput)
        invokedNextButtonPressedParametersList.append((tokenInput, verificationInput))
    }

    var invokedUpdateResendButtonState = false
    var invokedUpdateResendButtonStateCount = 0

    override func updateResendButtonState() {
        invokedUpdateResendButtonState = true
        invokedUpdateResendButtonStateCount += 1
    }
}

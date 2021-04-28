/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import Foundation

extension String {

	// MARK: - Shared

	static var holderTokenEntryModalNoTokenTitle: String {

		return Localization.string(for: "holder.tokenentry.modal.notoken.title")
	}

	static var holderTokenEntryModalNoTokenDetails: String {

		return Localization.string(for: "holder.tokenentry.modal.notoken.details")
	}


    // MARK: - "Regular" flow, i.e. not coming from QR/Universal Link

	static var holderTokenEntryRegularFlowTitle: String {

        return Localization.string(for: "holder.tokenentry.regularflow.title")
	}

	static var holderTokenEntryRegularFlowText: String {

        return Localization.string(for: "holder.tokenentry.regularflow.text")
	}

	static var holderTokenEntryRegularFlowTokenTitle: String {

        return Localization.string(for: "holder.tokenentry.regularflow.token.title")
	}

	static var holderTokenEntryRegularFlowTokenPlaceholder: String {

        return Localization.string(for: "holder.tokenentry.regularflow.token.placeholder")
	}

	static var holderTokenEntryRegularFlowVerificationTitle: String {

        return Localization.string(for: "holder.tokenentry.regularflow.verification.title")
	}

	static var holderTokenEntryRegularFlowVerificationPlaceholder: String {

        return Localization.string(for: "holder.tokenentry.regularflow.verification.placeholder")
	}

	static var holderTokenEntryRegularFlowVerificationInfo: String {

        return Localization.string(for: "holder.tokenentry.regularflow.verification.info")
	}

	static var holderTokenEntryRegularFlowErrorInvalidCode: String {

        return Localization.string(for: "holder.tokenentry.regularflow.error.invalid.code")
	}

	static var holderTokenEntryRegularFlowRetryTitle: String {

        return Localization.string(for: "holder.tokenentry.regularflow.retry.title")
	}

	static var holderTokenEntryRegularFlowNext: String {

        return Localization.string(for: "holder.tokenentry.regularflow.next")
	}

	static var holderTokenEntryRegularFlowConfirmResendVerificationAlertTitle: String {

        return Localization.string(for: "holder.tokenentry.regularflow.confirmresendverificationalert.title")
	}

	static var holderTokenEntryRegularFlowConfirmResendVerificationAlertMessage: String {

        return Localization.string(for: "holder.tokenentry.regularflow.confirmresendverificationalert.message")
	}

	static var holderTokenEntryRegularFlowConfirmResendVerificationAlertOkayButton: String {

        return Localization.string(for: "holder.tokenentry.regularflow.confirmresendverificationalert.okaybutton")
	}

	static var holderTokenEntryRegularFlowConfirmResendVerificationCancelButton: String {

        return Localization.string(for: "holder.tokenentry.regularflow.confirmresendverificationalert.cancelbutton")
	}

	static var holderTokenEntryRegularFlowNoTokenButton: String {

        return Localization.string(for: "holder.tokenentry.regularflow.button.notoken")
	}

	// MARK: - ---------
	// MARK: - "UniversalLink" (or QR Code) flow
	// MARK: - ---------

    static var holderTokenEntryUniversalLinkFlowTitle: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.title")
    }

    static var holderTokenEntryUniversalLinkFlowText: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.text")
    }

    static var holderTokenEntryUniversalLinkFlowTokenTitle: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.token.title")
    }

    static var holderTokenEntryUniversalLinkFlowTokenPlaceholder: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.token.placeholder")
    }

    static var holderTokenEntryUniversalLinkFlowVerificationTitle: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.verification.title")
    }

    static var holderTokenEntryUniversalLinkFlowVerificationPlaceholder: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.verification.placeholder")
    }

    static var holderTokenEntryUniversalLinkFlowVerificationInfo: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.verification.info")
    }

    static var holderTokenEntryUniversalLinkFlowErrorInvalidCode: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.error.invalid.code")
    }

    static var holderTokenEntryUniversalLinkFlowRetryTitle: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.retry.title")
    }

    static var holderTokenEntryUniversalLinkFlowNext: String {

        return Localization.string(for: "holder.tokenentry.universallinkflow.next")
    }

	static var holderTokenEntryUniversalLinkFlowConfirmResendVerificationAlertTitle: String {

		return Localization.string(for: "holder.tokenentry.universallinkflow.confirmresendverificationalert.title")
	}

	static var holderTokenEntryUniversalLinkFlowConfirmResendVerificationAlertMessage: String {

		return Localization.string(for: "holder.tokenentry.universallinkflow.confirmresendverificationalert.message")
	}

	static var holderTokenEntryUniversalLinkFlowConfirmResendVerificationAlertOkayButton: String {

		return Localization.string(for: "holder.tokenentry.universallinkflow.confirmresendverificationalert.okaybutton")
	}

	static var holderTokenEntryUniversalLinkFlowConfirmResendVerificationCancelButton: String {

		return Localization.string(for: "holder.tokenentry.universallinkflow.confirmresendverificationalert.cancelbutton")
	}

	static var holderTokenEntryUniversalLinkFlowNoTokenButton: String {

		return Localization.string(for: "holder.tokenentry.universallinkflow.button.notoken")
	}
}

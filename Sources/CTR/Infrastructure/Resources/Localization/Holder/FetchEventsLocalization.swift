//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension String {

	static var holderFetchEventsErrorNoResultsNetworkWasBusyTitle: String {

		return Localization.string(for: "holder.fetchevents.error.noresults.networkwasbusy.title")
	}

	static var holderFetchEventsErrorNoResultsNetworkWasBusyMessage: String {

		return Localization.string(for: "holder.fetchevents.error.noresults.networkwasbusy.message")
	}

	static var holderFetchEventsErrorNoResultsNetworkWasBusyButton: String {

		return Localization.string(for: "holder.fetchevents.error.noresults.networkwasbusy.button")
	}

	static var holderFetchEventsErrorNoResultsNetworkErrorTitle: String {

		return Localization.string(for: "holder.fetchevents.error.noresults.networkerror.title")
	}

	static func holderFetchEventsErrorNoResultsNetworkErrorMessage(localizedEventType: String) -> String {

		return localizedStringWithFormat(Localization.string(
			for: "holder.fetchevents.error.noresults.networkerror.message"),
			[localizedEventType]
		)
	}

	static var holderFetchEventsErrorNoResultsNetworkErrorButton: String {

		return Localization.string(for: "holder.fetchevents.error.noresults.networkerror.button")
	}

	static var holderFetchEventsWarningSomeResultsNetworkWasBusyTitle: String {

		return Localization.string(for: "holder.fetchevents.warning.someresults.networkwasbusy.title")
	}

	static var holderFetchEventsWarningSomeResultsNetworkWasBusyMessage: String {

		return Localization.string(for: "holder.fetchevents.warning.someresults.networkwasbusy.message")
	}

	static var holderFetchEventsWarningSomeResultsNetworkErrorTitle: String {

		return Localization.string(for: "holder.fetchevents.warning.someresults.networkerror.title")
	}

	static var holderFetchEventsWarningSomeResultsNetworkErrorMessage: String {

		return Localization.string(for: "holder.fetchevents.warning.someresults.networkerror.message")
	}
}



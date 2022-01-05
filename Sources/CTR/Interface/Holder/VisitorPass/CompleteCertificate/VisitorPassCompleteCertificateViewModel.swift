/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class VisitorPassCompleteCertificateViewModel: Logging {
	
	@Bindable private(set) var content: Content
	
	init(coordinatorDelegate: (HolderCoordinatorDelegate & OpenUrlProtocol)?) {
		
		self.content = Content(
			title: "Maak je bezoekersbewijs compleet",
			subTitle: "<p>Om je bezoekersbewijs compleet te maken heb je een negatieve testuitslag nodig van minder dan 24 uur oud.</p><p>Heb je nog geen coronatest gedaan? Maak dan eerst een afspraak.</p>",
			primaryActionTitle: "Testuitslag ophalen",
			primaryAction: {
				coordinatorDelegate?.userWishesToCreateANegativeTestQR()
			},
			secondaryActionTitle: "Maak een testafspraak",
			secondaryAction: {
				guard let url = URL(string: "https://coronacheck.nl") else { return }
				coordinatorDelegate?.openUrl(url, inApp: true)
			}
		)
	}
	// holder_completecertificate_title
	// holder_completecertificate_body
	// holder_completecertificate_link
	// holder_completecertificate_url
	// holder_completecertificate_button
}

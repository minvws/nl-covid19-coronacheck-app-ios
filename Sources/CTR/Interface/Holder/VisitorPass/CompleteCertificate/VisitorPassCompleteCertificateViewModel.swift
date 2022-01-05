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
			title: L.holder_completecertificate_title(),
			subTitle: L.holder_completecertificate_body(),
			primaryActionTitle: L.holder_completecertificate_button_fetchnegativetest(),
			primaryAction: {
				coordinatorDelegate?.userWishesToCreateANegativeTestQR()
			},
			secondaryActionTitle: L.holder_completecertificate_button_makeappointement(),
			secondaryAction: {
				guard let url = URL(string: L.holderUrlAppointment()) else { return }
				coordinatorDelegate?.openUrl(url, inApp: true)
			}
		)
	}
}

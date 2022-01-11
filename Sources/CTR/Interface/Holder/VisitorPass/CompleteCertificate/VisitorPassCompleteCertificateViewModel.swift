/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

final class VisitorPassCompleteCertificateViewModel: Logging {
	
	@Bindable private(set) var content: Content
	
	weak private var coordinatorDelegate: (HolderCoordinatorDelegate & OpenUrlProtocol)?
	
	init(coordinatorDelegate: (HolderCoordinatorDelegate & OpenUrlProtocol)?) {
	
		self.coordinatorDelegate = coordinatorDelegate
		
		self.content = Content(
			title: L.holder_completecertificate_title(),
			subTitle: L.holder_completecertificate_body(),
			primaryActionTitle: L.holder_completecertificate_button_fetchnegativetest(),
			primaryAction: {
				coordinatorDelegate?.userWishesToCreateANegativeTestQR()
			},
			secondaryActionTitle: nil,
			secondaryAction: nil
		)
	}
	
	func openUrl(_ url: URL) {
		
		coordinatorDelegate?.openUrl(url, inApp: true)
	}
}

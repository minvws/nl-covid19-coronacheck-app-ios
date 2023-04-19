/*
* Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Resources
import ReusableViews

class PaperProofStartScanningViewModel: ContentWithImageProtocol {
	
	var content: Shared.Observable<ReusableViews.ContentWithImageViewController.Content>
	
	init(coordinator: PaperProofCoordinatorDelegate) {
		
		content = Shared.Observable(
			value: ReusableViews.ContentWithImageViewController.Content(
				title: L.holder_paperproof_startscanning_title(),
				body: L.holder_paperproof_startscanning_body(),
				primaryAction: ContentWithImageViewController.Action(
					title: L.holder_paperproof_startscanning_button_startScanning(),
					action: { [weak coordinator] in
						coordinator?.userWishesToScanCertificate()
					}
				),
				secondaryAction: ContentWithImageViewController.Action(
					title: L.holder_paperproof_startscanning_button_whichProofs(),
					action: { [weak coordinator] in
						coordinator?.userWishesMoreInformationOnWhichProofsCanBeUsed()
					}
				),
				image: I.scannableQRs()
			)
		)
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class StartPaperCertificateViewModel: Logging {
	
	@Bindable private(set) var title: String = L.holderPapercertificateStartTitle()
	@Bindable private(set) var message: String = L.holderPapercertificateStartMessage()
	@Bindable private(set) var primaryButtonTitle = L.generalNext()
	
	weak var coordinator: PaperCertificateCoordinator?
	
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: PaperCertificateCoordinator) {
		
		self.coordinator = coordinator
	}
}

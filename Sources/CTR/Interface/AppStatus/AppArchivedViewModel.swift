/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

class AppArchivedViewModel: AppStatusViewModel {
	
	var title = Observable<String>(value: L.holder_archiveMode_title())
	var message = Observable<String>(value: L.holder_archiveMode_description())
	var actionTitle = Observable<String>(value: L.holder_archiveMode_button())
	var image = Observable<UIImage?>(value: I.endOfLife())
	var alert: Observable<AlertContent?> = Observable(value: nil)

	weak private var coordinator: AppCoordinatorDelegate?
	
	private var informationUrl: URL?
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - informationUrl: the store url
	///   - flavor: the app flavor (holder of verifier)
	init(coordinator: AppCoordinatorDelegate, informationUrl: URL?) {

		self.coordinator = coordinator
		self.informationUrl = informationUrl
	}
	
	func actionButtonTapped() {
		
		if let url = informationUrl {
			coordinator?.openUrl(url, completionHandler: nil)
		}
	}
}

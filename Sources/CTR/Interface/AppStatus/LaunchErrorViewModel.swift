/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Transport

class LaunchErrorViewModel: AppStatusViewModel {
	
	var title = Observable(value: L.appstatus_launchError_title())
	var message: Observable<String>
	var actionTitle = Observable(value: L.appstatus_launchError_button())
	var image = Observable<UIImage?>(value: I.launchError())
	var alert: Observable<AlertContent?> = Observable(value: nil)
	
	private let urlHandler: (URL) -> Void
	
	init(urlHandler: @escaping (URL) -> Void) {
		
		self.urlHandler = urlHandler
		self.message = Observable(value: L.appstatus_launchError_body("i 123 000 123"))
	}
	
	func actionButtonTapped() {
		
		exit(0)
	}
	
	func userDidTapURL(url: URL) {
		
		urlHandler(url)
	}
}

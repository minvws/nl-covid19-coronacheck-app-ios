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
	private let closeHandler: () -> Void
	
	init(errorCodes: [ErrorCode], urlHandler: @escaping (URL) -> Void, closeHandler: @escaping () -> Void) {
		
		self.closeHandler = closeHandler
		self.urlHandler = urlHandler
		self.message = Observable(value: L.appstatus_launchError_body(ErrorCode.flatten(errorCodes)))
	}
	
	func actionButtonTapped() {
		
		closeHandler()
	}
	
	func userDidTapURL(url: URL) {
		
		urlHandler(url)
	}
}

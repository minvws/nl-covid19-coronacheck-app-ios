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
	
	init() {
		message = Observable(value: L.appstatus_launchError_body("i 123 000 123"))
		
		
//		NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
//			exit(0)
//		}
	}
	
	func actionButtonTapped() {
		exit(0)
	}
}

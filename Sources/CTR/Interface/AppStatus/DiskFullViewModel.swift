/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import ReusableViews
import Resources

class DiskFullViewModel: AppStatusViewModel {
	
	var title = Observable(value: L.appstatus_diskfull_title())
	var message = Observable(value: L.appstatus_diskfull_body())
	var actionTitle = Observable(value: L.appstatus_diskfull_button())
	var image = Observable<UIImage?>(value: I.diskFull())
	var alert: Observable<AlertContent?> = Observable(value: nil)
	
	init() {
		NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
			exit(0)
		}
	}
	
	func actionButtonTapped() {
		exit(0)
	}
}

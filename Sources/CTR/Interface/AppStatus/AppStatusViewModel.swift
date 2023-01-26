/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import ReusableViews

protocol AppStatusViewModel {
	
	var title: Observable<String> { get }
	var message: Observable<String> { get }
	var actionTitle: Observable<String> { get }
	var image: Observable<UIImage?> { get }
	var alert: Observable<AlertContent?> { get }
	
	func actionButtonTapped()
	
	func userDidTapURL(url: URL)
}

extension AppStatusViewModel {
	
	func userDidTapURL(url: URL) {
		// Do nothing
	}
}

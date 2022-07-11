/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol ListOptionsProtocol: AnyObject {

	var title: Observable<String> { get }
	var message: Observable<String?> { get }
	var optionModels: Observable<[ListOptionsViewController.OptionModel]> { get }
	var bottomButton: Observable<ListOptionsViewController.OptionModel?> { get }
}

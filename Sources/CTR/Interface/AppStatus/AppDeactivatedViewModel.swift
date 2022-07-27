/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppDeactivatedViewModel: AppStatusViewModel {
	
	var title: Observable<String>
	var message: Observable<String>
	var actionTitle: Observable<String>
	var image = Observable<UIImage?>(value: I.endOfLife())
	var alert: Observable<AlertContent?> = Observable(value: nil)

	weak private var coordinator: AppCoordinatorDelegate?
	private var flavor: AppFlavor
	
	private var informationUrl: URL?
	
	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - informationUrl: the store url
	///   - flavor: the app flavor (holder of verifier)
	init(coordinator: AppCoordinatorDelegate, informationUrl: URL?, flavor: AppFlavor) {

		title = Observable(value: flavor == .holder ? L.holder_endOfLife_title() : L.verifier_endOfLife_title())
		message = Observable(value: flavor == .holder ? L.holder_endOfLife_description() : L.verifier_endOfLife_description())
		actionTitle = Observable(value: flavor == .holder ? L.holder_endOfLife_button() : L.verifier_endOfLife_button())
	
		self.coordinator = coordinator
		self.flavor = flavor
		self.informationUrl = informationUrl
	}
	
	func actionButtonTapped() {
		
		guard let url = informationUrl else {
			alert.value = AlertContent(
				title: L.generalErrorTitle(),
				subTitle: flavor == .holder ? L.holder_endOfLife_errorMessage() : L.verifier_endOfLife_errorMessage(),
				okAction: AlertContent.Action.okay
			)
			return
		}
		coordinator?.openUrl(url, completionHandler: nil)
	}
}

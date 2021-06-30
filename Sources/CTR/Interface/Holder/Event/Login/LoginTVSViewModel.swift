/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LoginTVSViewModel: Logging {

	private weak var coordinator: EventCoordinatorDelegate?
	private weak var openIdManager: OpenIdManaging?

	private var eventMode: EventMode

	@Bindable private(set) var title: String

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable private(set) var alert: LoginTVSViewController.AlertContent?

	init(
		coordinator: EventCoordinatorDelegate,
		eventMode: EventMode,
		openIdManager: OpenIdManaging = Services.openIdManager) {

		self.coordinator = coordinator
		self.openIdManager = openIdManager
		self.eventMode = eventMode

		switch eventMode {
			case .recovery:
				title = L.holderRecoveryListTitle()
			case .test:
				title = L.holderTestListTitle()
			case .vaccination:
				title = L.holderVaccinationListTitle()
		}
	}

	func cancel() {

		self.coordinator?.loginTVSScreenDidFinish(.back(eventMode: eventMode))
	}

	/// Login at the GGD
	/// - Parameter presentingViewController: the presenting view controller
	func login(_ presentingViewController: UIViewController?) {

		shouldShowProgress = true

		guard let viewController = presentingViewController else {
			logError("Can't present login for GGD")
			shouldShowProgress = false
			alert = LoginTVSViewController.AlertContent(
				title: .errorTitle,
				subTitle: .technicalErrorText,
				okTitle: .ok
			)
			return
		}

		openIdManager?.requestAccessToken(presenter: viewController) { accessToken in

			self.shouldShowProgress = false

			if let token = accessToken {
				self.coordinator?.loginTVSScreenDidFinish(.continue(value: token, eventMode: self.eventMode))
			} else {
				self.alert = LoginTVSViewController.AlertContent(
					title: .errorTitle,
					subTitle: .technicalErrorText,
					okTitle: .ok
				)
			}
		} onError: { error in
			self.shouldShowProgress = false
			self.logError("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
			self.coordinator?.loginTVSScreenDidFinish(.errorRequiringRestart(error: error, eventMode: self.eventMode))
		}
	}
}

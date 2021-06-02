/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum LoginTVSMode {
	case test
	case vaccination
}

class LoginTVSViewModel: Logging {

	weak var coordinator: EventCoordinatorDelegate?
	weak var openIdManager: OpenIdManaging?

	var mode: LoginTVSMode

	@Bindable private(set) var title: String

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable private(set) var alert: LoginTVSViewController.AlertContent?

	init(
		coordinator: EventCoordinatorDelegate,
		mode: LoginTVSMode = .vaccination,
		openIdManager: OpenIdManaging = Services.openIdManager) {

		self.coordinator = coordinator
		self.openIdManager = openIdManager
		self.mode = mode

		self.title = mode == .vaccination ? .holderVaccinationListTitle : .holderTestListTitle
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

		openIdManager?.requestAccessToken(presenter: viewController) { [weak self] accessToken in

			self?.shouldShowProgress = false

			if let token = accessToken {
				self?.coordinator?.loginTVSScreenDidFinish(.continue(value: token))
			} else {
				self?.alert = LoginTVSViewController.AlertContent(
					title: .errorTitle,
					subTitle: .technicalErrorText,
					okTitle: .ok
				)
			}
		} onError: { [weak self] error in
			self?.shouldShowProgress = false
			self?.logError("Authorization error: \(error?.localizedDescription ?? "Unknown error")")
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				self?.alert = LoginTVSViewController.AlertContent(
					title: .errorTitle,
					subTitle: String(format: .technicalErrorCustom, error?.localizedDescription ?? ""),
					okTitle: .ok
				)
			}
		}
	}
}

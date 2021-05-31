/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

enum EventScreenResult: Equatable {

	/// The user wants to go back a scene
	case back

	/// Stop with vaccination flow,
	case stop

	/// Continue with the next step in the flow
	case `continue`(value: String?)

	/// Show the vaccination events
	case remoteVaccinationEvents(events: [RemoteVaccinationEvent])

	/// Show some more information
	case moreInformation(title: String, body: String)

	static func == (lhs: EventScreenResult, rhs: EventScreenResult) -> Bool {
		switch (lhs, rhs) {
			case (.back, .back), (.stop, .stop), (.continue, .continue):
				return true
			case (let .moreInformation(lhsTitle, lhsBody), let .moreInformation(rhsTitle, rhsBody)):
				return (lhsTitle, lhsBody) == (rhsTitle, rhsBody)
			case (let remoteVaccinationEvents(lhsEvents), let remoteVaccinationEvents(rhsEvents)):

				if lhsEvents.count != rhsEvents.count {
					return false
				}

				for index in 0 ..< lhsEvents.count {

					if lhsEvents[index].wrapper != rhsEvents[index].wrapper ||
						lhsEvents[index].signedResponse != rhsEvents[index].signedResponse {
						return false
					}
				}
				return true

			default:
				return false
		}
	}
}

protocol EventCoordinatorDelegate: AnyObject {

	func vaccinationStartScreenDidFinish(_ result: EventScreenResult)

	func loginTVSScreenDidFinish(_ result: EventScreenResult)

	func fetchEventsScreenDidFinish(_ result: EventScreenResult)

	func listEventsScreenDidFinish(_ result: EventScreenResult)
}

protocol EventFlowDelegate: AnyObject {

	/// The event flow is finished
	func eventFlowDidComplete()

	func eventFlowDidCancel()
}

class EventCoordinator: Coordinator, Logging {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: EventFlowDelegate?

	private var bottomSheetTransitioningDelegate = BottomSheetTransitioningDelegate() // swiftlint:disable:this weak_delegate

	/// Initiailzer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the vaccination flow delegate
	init(
		navigationController: UINavigationController,
		delegate: EventFlowDelegate) {

		self.navigationController = navigationController
		self.delegate = delegate
	}

	func start() {

		let viewController = VaccinationStartViewController(
			viewModel: VaccinationStartViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	func startWithListTestEvents(testEvents: [RemoteTestEvent]) {

		navigateToListEvents([], testEvents: testEvents, sourceMode: .negativeTest)
	}

	// MARK: - Universal Link handling

	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}

	// MARK: Private functions

	private func navigateToLogin() {

		let viewController = LoginTVSViewController(
			viewModel: LoginTVSViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)

	}

	private func navigateToFetchEvents(token: String) {
		let viewController = FetchEventsViewController(
			viewModel: FetchEventsViewModel(
				coordinator: self,
				tvsToken: token
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}

	private func navigateToListEvents(
		_ vaccinationEvents: [RemoteVaccinationEvent],
		testEvents: [RemoteTestEvent],
		sourceMode: ListEventSourceMode = .vaccination) {

		let viewController = ListEventsViewController(
			viewModel: ListEventsViewModel(
				coordinator: self,
				sourceMode: sourceMode,
				remoteVaccinationEvents: vaccinationEvents,
				remoteTestEvents: testEvents
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}

	private func navigateToMoreInformation(_ title: String, body: String) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body
			)
		)

		viewController.transitioningDelegate = bottomSheetTransitioningDelegate
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .coverVertical

		navigationController.visibleViewController?.present(viewController, animated: true, completion: nil)
	}
}

extension EventCoordinator: Dismissable {

	func dismiss() {

		navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
	}
}

extension EventCoordinator: EventCoordinatorDelegate {

	func vaccinationStartScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .back, .stop:
				delegate?.eventFlowDidCancel()
			case .continue:
				navigateToLogin()
			default:
				break
		}
	}

	func loginTVSScreenDidFinish(_ result: EventScreenResult) {

		switch result {

			case let .continue(value: token):
				if let token = token {
					navigateToFetchEvents(token: token)
				} else {
					start()
				}
			default:
				break
		}
	}

	func fetchEventsScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .stop:
				delegate?.eventFlowDidComplete()
			case .back:
				if let vaccineStartViewController = navigationController.viewControllers
					.first(where: { $0 is VaccinationStartViewController }) {

					navigationController.popToViewController(
						vaccineStartViewController,
						animated: true
					)
				}
			case let .remoteVaccinationEvents(remoteEvents):
				navigateToListEvents(remoteEvents, testEvents: [])
			default:
				break
		}
	}

	func listEventsScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .stop, .continue:
				delegate?.eventFlowDidComplete()
			case .back:
				if let vaccineStartViewController = navigationController.viewControllers
					.first(where: { $0 is VaccinationStartViewController }) {

					navigationController.popToViewController(
						vaccineStartViewController,
						animated: true
					)
				}
			case let .moreInformation(title, body):
				navigateToMoreInformation(title, body: body)
			default:
				break
		}
	}
}

extension EventCoordinator: OpenUrlProtocol {

	/// Open a url
	/// - Parameters:
	///   - url: The url to open
	///   - inApp: True if we should open the url in a in-app browser, False if we want the OS to handle the url
	func openUrl(_ url: URL, inApp: Bool) {

		var shouldOpenInApp = inApp
		if url.scheme == "tel" {
			// Do not open phone numbers in app, doesn't work & will crash.
			shouldOpenInApp = false
		}

		if shouldOpenInApp {
			let safariController = SFSafariViewController(url: url)
			navigationController.viewControllers.last?.present(safariController, animated: true)
		} else {
			UIApplication.shared.open(url)
		}
	}
}

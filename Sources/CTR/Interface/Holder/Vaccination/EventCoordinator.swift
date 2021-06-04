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
	case `continue`(value: String?, eventMode: EventMode)

	/// Show the vaccination events
	case showEvents(events: [RemoteVaccinationEvent], eventMode: EventMode)

	/// Show some more information
	case moreInformation(title: String, body: String)

	static func == (lhs: EventScreenResult, rhs: EventScreenResult) -> Bool {
		switch (lhs, rhs) {
			case (.back, .back), (.stop, .stop), (.continue, .continue):
				return true
			case (let .moreInformation(lhsTitle, lhsBody), let .moreInformation(rhsTitle, rhsBody)):
				return (lhsTitle, lhsBody) == (rhsTitle, rhsBody)
			case (let showEvents(lhsEvents, lhsMode), let showEvents(rhsEvents, rhsMode)):

				if lhsEvents.count != rhsEvents.count {
					return false
				}

				if lhsMode != rhsMode {
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

		navigateToListEvents([], testEvents: testEvents, eventMode: .test, sourceMode: .negativeTest)
	}

	func startWithTVS(eventMode: EventMode) {
		
		navigateToLogin(eventMode: eventMode)
	}

	// MARK: - Universal Link handling

	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}

	// MARK: Private functions

	private func navigateToLogin(eventMode: EventMode) {

		let viewController = LoginTVSViewController(
			viewModel: LoginTVSViewModel(
				coordinator: self,
				eventMode: eventMode
			)
		)
		navigationController.pushViewController(viewController, animated: true)

	}

	private func navigateToFetchEvents(token: String, eventMode: EventMode) {
		let viewController = FetchEventsViewController(
			viewModel: FetchEventsViewModel(
				coordinator: self,
				tvsToken: token,
				eventMode: eventMode
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}

	private func navigateToListEvents(
		_ vaccinationEvents: [RemoteVaccinationEvent],
		testEvents: [RemoteTestEvent],
		eventMode: EventMode,
		sourceMode: ListEventSourceMode = .vaccination) {

		let viewController = ListEventsViewController(
			viewModel: ListEventsViewModel(
				coordinator: self,
				sourceMode: sourceMode,
				eventMode: eventMode,
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

	private func navigateBackToVaccinationStart() {

		if let vaccineStartViewController = navigationController.viewControllers
			.first(where: { $0 is VaccinationStartViewController }) {

			navigationController.popToViewController(
				vaccineStartViewController,
				animated: true
			)
		}
	}
}

extension EventCoordinator: EventCoordinatorDelegate {

	func vaccinationStartScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .back, .stop:
				delegate?.eventFlowDidCancel()
			case let .continue(_, eventMode):
				navigateToLogin(eventMode: eventMode)
			default:
				break
		}
	}

	func loginTVSScreenDidFinish(_ result: EventScreenResult) {

		switch result {

			case let .continue(value: token, eventMode: eventMode):
				if let token = token {
					navigateToFetchEvents(token: token, eventMode: eventMode)
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
				navigateBackToVaccinationStart()
			case let .showEvents(remoteEvents, eventMode):
				navigateToListEvents(remoteEvents, testEvents: [], eventMode: eventMode)
			default:
				break
		}
	}

	func listEventsScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .stop, .continue:
				delegate?.eventFlowDidComplete()
			case .back:
				navigateBackToVaccinationStart()
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

extension EventCoordinator: Dismissable {

	func dismiss() {

		navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
	}
}

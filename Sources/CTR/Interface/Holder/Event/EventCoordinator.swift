/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SafariServices

enum EventMode: String {

	case recovery
	case paperflow
	case test
	case vaccination

	var localized: String {
		switch self {
			case .recovery: return L.generalRecoverystatement()
			case .paperflow: return L.generalPaperflow()
			case .test: return L.generalTestresult()
			case .vaccination: return L.generalVaccination()
		}
	}
}

enum EventScreenResult: Equatable {

	/// The user wants to go back a scene
	case back(eventMode: EventMode)

	/// Stop with vaccination flow,
	case stop

	/// Skip back to the beginning of the flow
	case errorRequiringRestart(eventMode: EventMode)

	/// Continue with the next step in the flow
	case `continue`(value: String?, eventMode: EventMode)

	/// Show the vaccination events
	case showEvents(events: [RemoteEvent], eventMode: EventMode, eventsMightBeMissing: Bool)

	/// Show some more information
	case moreInformation(title: String, body: String, hideBodyForScreenCapture: Bool)
	
	/// Show event details
	case showEventDetails(title: String, details: [EventDetails])

	static func == (lhs: EventScreenResult, rhs: EventScreenResult) -> Bool {
		switch (lhs, rhs) {
			case (.back, .back), (.stop, .stop), (.continue, .continue):
				return true
			case (let .moreInformation(lhsTitle, lhsBody, lhsCapture), let .moreInformation(rhsTitle, rhsBody, rhsCapture)):
				return (lhsTitle, lhsBody, lhsCapture) == (rhsTitle, rhsBody, rhsCapture)
			case (let showEvents(lhsEvents, lhsMode, lhsComplete), let showEvents(rhsEvents, rhsMode, rhsComplete)):

				if lhsEvents.count != rhsEvents.count || lhsMode != rhsMode || lhsComplete != rhsComplete {
					return false
				}

				for index in 0 ..< lhsEvents.count {

					if lhsEvents[index].wrapper != rhsEvents[index].wrapper ||
						lhsEvents[index].signedResponse != rhsEvents[index].signedResponse {
						return false
					}
				}
				return true
			case (let showEventDetails(lhsTitle, lhsDetails), let showEventDetails(rhsTitle, rhsDetails)):
				return (lhsTitle, lhsDetails) == (rhsTitle, rhsDetails)

			case (let errorRequiringRestart(lhsMode), let errorRequiringRestart(rhsMode)):
				return lhsMode == rhsMode
				
			default:
				return false
		}
	}
}

protocol EventCoordinatorDelegate: AnyObject {

	func eventStartScreenDidFinish(_ result: EventScreenResult)

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

	/// Initializer
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

		startWithVaccination()
	}

	func startWithVaccination() {

		startWith(.vaccination)
	}

	func startWithRecovery() {

		startWith(.recovery)
	}

	func startWithListTestEvents(_ events: [RemoteEvent]) {

		navigateToListEvents(events, eventMode: .test, eventsMightBeMissing: false)
	}

	func startWithScannedEvent(_ event: RemoteEvent) {

		navigateToListEvents([event], eventMode: .paperflow, eventsMightBeMissing: false)
	}

	func startWithTVS(eventMode: EventMode) {
		
		navigateToLogin(eventMode: eventMode)
	}

	// MARK: - Universal Link handling

	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}

	// MARK: Private functions

	private func startWith(_ eventMode: EventMode) {

		let viewController = EventStartViewController(
			viewModel: EventStartViewModel(
				coordinator: self,
				eventMode: eventMode
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

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
		_ remoteEvents: [RemoteEvent],
		eventMode: EventMode,
		eventsMightBeMissing: Bool) {

		let viewController = ListEventsViewController(
			viewModel: ListEventsViewModel(
				coordinator: self,
				eventMode: eventMode,
				remoteEvents: remoteEvents,
				eventsMightBeMissing: eventsMightBeMissing
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}

	private func navigateToMoreInformation(_ title: String, body: String, hideBodyForScreenCapture: Bool) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body,
				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: true)
				},
				hideBodyForScreenCapture: hideBodyForScreenCapture
			)
		)

		viewController.transitioningDelegate = bottomSheetTransitioningDelegate
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .coverVertical

		navigationController.visibleViewController?.present(viewController, animated: true, completion: nil)
	}
	
	private func navigateToEventDetails(_ title: String, details: [EventDetails]) {
		
		let viewController = EventDetailsViewController(
			viewModel: EventDetailsViewModel(
				coordinator: self,
				title: title,
				details: details,
				hideBodyForScreenCapture: true
			)
		)

		viewController.transitioningDelegate = bottomSheetTransitioningDelegate
		viewController.modalPresentationStyle = .custom
		viewController.modalTransitionStyle = .coverVertical

		navigationController.visibleViewController?.present(viewController, animated: true, completion: nil)
	}

	private func navigateBackToEventStart() {

		if let eventStartViewController = navigationController.viewControllers
			.first(where: { $0 is EventStartViewController }) {

			navigationController.popToViewController(
				eventStartViewController,
				animated: true
			)
		}
	}

	private func navigateBackToTestStart() {
		
		let popBackToViewController = navigationController.viewControllers.first {
			
			switch $0 {
				case is ChooseTestLocationViewController:
					return true
				// Fallback when GGD is not available
				case is ChooseQRCodeTypeViewController:
					return true
				default:
					return false
			}
		}
		if let popBackToViewController = popBackToViewController {
			
			navigationController.popToViewController(
				popBackToViewController,
				animated: true
			)
		}
	}
}

extension EventCoordinator: EventCoordinatorDelegate {

	func eventStartScreenDidFinish(_ result: EventScreenResult) {

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

			case .errorRequiringRestart(let eventMode):
				handleErrorRequiringRestart(eventMode: eventMode)

			case .back(let eventMode):
				switch eventMode {
					case .test:
						navigateBackToTestStart()
					case .vaccination, .recovery:
						navigateBackToEventStart()
					case .paperflow:
					break
				}
			case .stop:
				delegate?.eventFlowDidComplete()

			default:
				break
		}
	}

	func fetchEventsScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .stop:
				delegate?.eventFlowDidComplete()
				
			case .back(let eventMode):
				switch eventMode {
					case .test:
						navigateBackToTestStart()
					case .recovery, .vaccination:
						navigateBackToEventStart()
					case .paperflow:
						break
				}
			case let .showEvents(remoteEvents, eventMode, eventsMightBeMissing):
				navigateToListEvents(remoteEvents, eventMode: eventMode, eventsMightBeMissing: eventsMightBeMissing)

			default:
				break
		}
	}

	func listEventsScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .stop, .continue:
				delegate?.eventFlowDidComplete()
			case .back(let eventMode):
				switch eventMode {
					case .test:
						navigateBackToTestStart()
					case .recovery, .vaccination:
						navigateBackToEventStart()
					case .paperflow:
						delegate?.eventFlowDidCancel()
				}
			case let .moreInformation(title, body, hideBodyForScreenCapture):
				navigateToMoreInformation(title, body: body, hideBodyForScreenCapture: hideBodyForScreenCapture)
			case let .showEventDetails(title, details):
				navigateToEventDetails(title, details: details)
			default:
				break
		}
	}

	private func handleErrorRequiringRestart(eventMode: EventMode) {
		let popback = navigationController.viewControllers.first {
			// arrange `case`s in the order of matching priority
			switch $0 {
				case is EventStartViewController:
					return true
				case is ChooseTestLocationViewController:
					return true
				default:
					return false
			}
		}

		let presentError = {
			let alertController = UIAlertController(
				title: L.holderErrorstateLoginTitle(),
				message: {
					switch eventMode {
						case .recovery:
							return L.holderErrorstateLoginMessageRecovery()
						case .paperflow:
							return "" // HKVI is not a part of this flow
						case .test:
							return L.holderErrorstateLoginMessageTest()
						case .vaccination:
							return L.holderErrorstateLoginMessageVaccination()
					}
				}(),
				preferredStyle: .alert
			)

			alertController.addAction(.init(title: L.generalClose(), style: .default, handler: nil))
			self.navigationController.present(alertController, animated: true, completion: nil)
		}

		if let popback = popback {
			navigationController.popToViewController(popback, animated: true, completion: presentError)
		} else {
			navigationController.popToRootViewController(animated: true, completion: presentError)
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
			if let presentedViewController = navigationController.presentedViewController {
				presentedViewController.presentingViewController?.dismiss(animated: true, completion: {
					self.navigationController.viewControllers.last?.present(safariController, animated: true)
				})
			} else {
				navigationController.viewControllers.last?.present(safariController, animated: true)
			}
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

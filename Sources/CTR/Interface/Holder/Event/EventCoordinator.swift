/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum EventScreenResult: Equatable {

	/// The user wants to go back a scene
	case back(eventMode: EventMode)
	
	case backSwipe

	/// Stop with vaccination flow,
	case stop

	/// Skip back to the beginning of the flow
	case errorRequiringRestart(eventMode: EventMode)

	case error(content: Content, backAction: () -> Void)

	/// Continue with the next step in the flow
	case `continue`(eventMode: EventMode)

	// LoginTVS happy path:
	case didLogin(token: TVSAuthorizationToken, eventMode: EventMode)
	
	/// Show the vaccination events
	case showEvents(events: [RemoteEvent], eventMode: EventMode, eventsMightBeMissing: Bool)

	/// Show some more information
	case moreInformation(title: String, body: String, hideBodyForScreenCapture: Bool)
	
	/// Show event details
	case showEventDetails(title: String, details: [EventDetails], footer: String?)

	case startWithPositiveTest
	
	static func == (lhs: EventScreenResult, rhs: EventScreenResult) -> Bool {
		switch (lhs, rhs) {
			case (.back, .back), (.stop, .stop), (.continue, .continue), (.startWithPositiveTest, .startWithPositiveTest), (.backSwipe, .backSwipe):
				return true
			case let (.didLogin(lhsToken, lhsEventMode), .didLogin(rhsToken, rhsEventMode)):
				return (lhsToken, lhsEventMode) == (rhsToken, rhsEventMode)
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
			case (let showEventDetails(lhsTitle, lhsDetails, lhsFooter), let showEventDetails(rhsTitle, rhsDetails, rhsFooter)):
				return (lhsTitle, lhsDetails, lhsFooter) == (rhsTitle, rhsDetails, rhsFooter)

			case (let errorRequiringRestart(lhsMode), let errorRequiringRestart(rhsMode)):
				return lhsMode == rhsMode

			case (let error(lhsContent, _), let error(rhsContent, _)):
				return lhsContent == rhsContent

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
	
	func eventFlowDidCancelFromBackSwipe()
}

class EventCoordinator: Coordinator, Logging, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: EventFlowDelegate?

	private var tvsToken: TVSAuthorizationToken?
	
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

	func startWithNegativeTest() {
		
		startWith(.test)
	}
	
	func startWithVaccination() {

		startWith(.vaccination)
	}

	func startWithRecovery() {

		startWith(.recovery)
	}

	func startWithPositiveTest() {
		if let tvsToken = tvsToken, tvsToken.expiration > Date(timeIntervalSinceNow: 10) {
			navigateToFetchEvents(token: tvsToken, eventMode: .positiveTest)
		} else {
			startWith(.positiveTest)
		}
	}

	func startWithListTestEvents(_ events: [RemoteEvent]) {

		navigateToListEvents(events, eventMode: .test, eventsMightBeMissing: false)
	}

	func startWithScannedEvent(_ event: RemoteEvent) {

		navigateToListEvents([event], eventMode: .paperflow, eventsMightBeMissing: false)
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

	private func navigateToFetchEvents(token: TVSAuthorizationToken, eventMode: EventMode) {
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
				identityChecker: IdentityChecker(),
				eventsMightBeMissing: eventsMightBeMissing,
				greenCardLoader: Current.greenCardLoader
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
		presentAsBottomSheet(viewController)
	}
	
	private func navigateToEventDetails(_ title: String, details: [EventDetails], footer: String?) {
		
		let viewController = EventDetailsViewController(
			viewModel: EventDetailsViewModel(
				coordinator: self,
				title: title,
				details: details,
				footer: footer,
				hideBodyForScreenCapture: true
			)
		)
		presentAsBottomSheet(viewController)
	}

	private func presentAsBottomSheet(_ viewController: UIViewController) {

		navigationController.visibleViewController?.presentBottomSheet(viewController)
	}

	@discardableResult private func navigateBackToEventStart() -> Bool {

		if let eventStartViewController = navigationController.viewControllers
			.first(where: { $0 is EventStartViewController }) {

			navigationController.popToViewController(
				eventStartViewController,
				animated: true
			)
			return true
		}
		return false
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

	private func displayError(content: Content, backAction: @escaping () -> Void) {

		let viewController = ErrorStateViewController(
			viewModel: ErrorStateViewModel(
				content: content,
				backAction: backAction
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}
}

extension EventCoordinator: EventCoordinatorDelegate {

	func eventStartScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case let .back(eventMode): handleBackAction(eventMode: eventMode)
			case .stop: delegate?.eventFlowDidCancel()
			case .backSwipe: delegate?.eventFlowDidCancelFromBackSwipe()
			case let .continue(eventMode): navigateToLogin(eventMode: eventMode)
			default: break
		}
	}

	private func handleBackAction(eventMode: EventMode) {
		
		if eventMode == .positiveTest,
		   navigationController.viewControllers.filter({ $0 is EventStartViewController }).count > 1,
		   let listEventViewController = navigationController.viewControllers.first(where: { $0 is ListEventsViewController }) {
			
			navigationController.popToViewController(
				listEventViewController,
				animated: true
			)
		} else {
			delegate?.eventFlowDidCancel()
		}
	}

	func loginTVSScreenDidFinish(_ result: EventScreenResult) {

		switch result {

			case let .didLogin(token, eventMode):
				self.tvsToken = token
				navigateToFetchEvents(token: token, eventMode: eventMode)

			case .errorRequiringRestart(let eventMode):
				handleErrorRequiringRestart(eventMode: eventMode)

			case let .error(content: content, backAction: backAction):
				displayError(content: content, backAction: backAction)

			case .back(let eventMode):
				goBack(eventMode)
	
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
				goBack(eventMode)

			case let .error(content: content, backAction: backAction):
				displayError(content: content, backAction: backAction)

			case let .showEvents(remoteEvents, eventMode, eventsMightBeMissing):
				navigateToListEvents(remoteEvents, eventMode: eventMode, eventsMightBeMissing: eventsMightBeMissing)

			case .startWithPositiveTest:
				// route after international QR only, and backend says token expired, while our check says valid.
				tvsToken = nil
				startWithPositiveTest()
			default:
				break
		}
	}

	private func goBack(_ eventMode: EventMode) {

		switch eventMode {
			case .recovery, .vaccination, .positiveTest:
				navigateBackToEventStart()
			case .test:
				if !navigateBackToEventStart() {
					navigateBackToTestStart()
				}
			case .paperflow:
				delegate?.eventFlowDidCancel()
		}
	}

	func listEventsScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .stop, .continue:
				delegate?.eventFlowDidComplete()
			case .back(let eventMode):
				goBack(eventMode)
			case let .error(content: content, backAction: backAction):
				displayError(content: content, backAction: backAction)
			case let .moreInformation(title, body, hideBodyForScreenCapture):
				navigateToMoreInformation(title, body: body, hideBodyForScreenCapture: hideBodyForScreenCapture)
			case let .showEventDetails(title, details, footer):
				navigateToEventDetails(title, details: details, footer: footer)
			case .startWithPositiveTest:
				startWithPositiveTest()
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
						case .test, .positiveTest:
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

extension EventCoordinator: Dismissable {

	func dismiss() {

		navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
	}
}

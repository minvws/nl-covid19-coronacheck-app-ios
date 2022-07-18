/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum EventScreenResult: Equatable {

	/// The user want to start an alternavite (no digid) route
	case alternativeRoute(eventMode: EventMode)
	
	/// The user wants to go back a scene
	case back(eventMode: EventMode)
	
	case backSwipe

	/// Stop with vaccination flow,
	case stop

	/// Skip back to the beginning of the flow
	case errorRequiringRestart(eventMode: EventMode, authenticationMode: AuthenticationMode)

	case error(content: Content, backAction: () -> Void)

	/// Continue with the next step in the flow
	case `continue`(eventMode: EventMode)

	// Login happy path:
	case didLogin(token: String, authenticationMode: AuthenticationMode, eventMode: EventMode)
	
	/// Show the vaccination events
	case showEvents(events: [RemoteEvent], eventMode: EventMode, eventsMightBeMissing: Bool)

	/// Show some more information
	case moreInformation(title: String, body: String, hideBodyForScreenCapture: Bool)
	
	/// Show event details
	case showEventDetails(title: String, details: [EventDetails], footer: String?)
	
	case shouldCompleteVaccinationAssessment
	
	case showHints([String])
	
	static func == (lhs: EventScreenResult, rhs: EventScreenResult) -> Bool {
		switch (lhs, rhs) {
			case (.back, .back), (.stop, .stop), (.backSwipe, .backSwipe),
				(.shouldCompleteVaccinationAssessment, .shouldCompleteVaccinationAssessment):
				return true
				
			case (let .alternativeRoute(lhsEventMode), let .alternativeRoute(rhsEventMode)):
				return lhsEventMode == rhsEventMode
				
			case let (.didLogin(lhsToken, lhsAuthenticationMode, lhsEventMode), .didLogin(rhsToken, rhsAuthenticationMode, rhsEventMode)):
				return (lhsToken, lhsAuthenticationMode, lhsEventMode) == (rhsToken, rhsAuthenticationMode, rhsEventMode)
				
			case (let .moreInformation(lhsTitle, lhsBody, lhsCapture), let .moreInformation(rhsTitle, rhsBody, rhsCapture)):
				return (lhsTitle, lhsBody, lhsCapture) == (rhsTitle, rhsBody, rhsCapture)
				
			case (let .showEvents(lhsEvents, lhsMode, lhsComplete), let .showEvents(rhsEvents, rhsMode, rhsComplete)):

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
			case (let .showEventDetails(lhsTitle, lhsDetails, lhsFooter), let .showEventDetails(rhsTitle, rhsDetails, rhsFooter)):
				return (lhsTitle, lhsDetails, lhsFooter) == (rhsTitle, rhsDetails, rhsFooter)

			case (let .errorRequiringRestart(lhsEventMode, lhsAuthenticationMode), let .errorRequiringRestart(rhsEventMode, rhsAuthenticationMode)):
				return (lhsEventMode, lhsAuthenticationMode) == (rhsEventMode, rhsAuthenticationMode)

			case (let .error(lhsContent, _), let .error(rhsContent, _)):
				return lhsContent == rhsContent
				
			case (let .continue(lhsEventMode), let .continue(rhsEventMode)):
				return lhsEventMode == rhsEventMode
			
			case let (.showHints(lhsHints), .showHints(rhsHints)):
				return lhsHints == rhsHints
			
			default:
				return false
		}
	}
}

protocol EventCoordinatorDelegate: AnyObject {

	func eventStartScreenDidFinish(_ result: EventScreenResult)

	func authenticationScreenDidFinish(_ result: EventScreenResult)

	func fetchEventsScreenDidFinish(_ result: EventScreenResult)

	func listEventsScreenDidFinish(_ result: EventScreenResult)
	
	func showHintsScreenDidFinish(_ result: EventScreenResult)
}

protocol EventFlowDelegate: AnyObject {

	/// The event flow is finished
	func eventFlowDidComplete()
	
	/// The event flow is finished, but go to the vaccination assessment entry
	func eventFlowDidCompleteButVisitorPassNeedsCompletion()

	func eventFlowDidCancel()
	
	func eventFlowDidCancelFromBackSwipe()
}

class EventCoordinator: Coordinator, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: EventFlowDelegate?
	
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

	func startWithListTestEvents(_ events: [RemoteEvent], originalMode: EventMode) {
		
		var mode: EventMode = .test
		
		if let event = events.first?.wrapper.events?.first {
			
			if event.hasVaccinationAssessment {
				mode = .vaccinationassessment
			} else if event.hasPaperCertificate {
				mode = .paperflow
			} else if event.hasPositiveTest {
				mode = .recovery
			} else if event.hasNegativeTest {
				mode = .test
			} else if event.hasRecovery {
				mode = .recovery
			} else if event.hasVaccination {
				mode = .vaccination
			}
		}

		navigateToListEvents(events, eventMode: mode, originalMode: originalMode, eventsMightBeMissing: false)
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

		let viewController = RemoteEventStartViewController(
			viewModel: RemoteEventStartViewModel(
				coordinator: self,
				eventMode: eventMode
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	private func navigateToAuthentication(eventMode: EventMode, authenticationMode: AuthenticationMode = .manyAuthenticationExchange) {

		let viewController = AuthenticationViewController(
			viewModel: AuthenticationViewModel(
				coordinator: self,
				eventMode: eventMode,
				authenticationMode: authenticationMode
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	private func navigateToFetchEvents(token: String, authenticationMode: AuthenticationMode, eventMode: EventMode) {
		let viewController = FetchRemoteEventsViewController(
			viewModel: FetchRemoteEventsViewModel(
				coordinator: self,
				token: token,
				authenticationMode: authenticationMode,
				eventMode: eventMode
			)
		)

		navigationController.pushViewController(viewController, animated: false)
	}

	private func navigateToListEvents(
		_ remoteEvents: [RemoteEvent],
		eventMode: EventMode,
		originalMode: EventMode? = nil,
		eventsMightBeMissing: Bool) {

		let viewController = ListRemoteEventsViewController(
			viewModel: ListRemoteEventsViewModel(
				coordinator: self,
				eventMode: eventMode,
				originalMode: originalMode,
				remoteEvents: remoteEvents,
				eventsMightBeMissing: eventsMightBeMissing,
				greenCardLoader: Current.greenCardLoader
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}

	private func navigateToMoreInformation(_ title: String, body: String, hideBodyForScreenCapture: Bool) {

		let viewController = BottomSheetContentViewController(
			viewModel: BottomSheetContentViewModel(
				content: Content(
					title: title,
					body: body
				),
				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: true)
				},
				hideBodyForScreenCapture: hideBodyForScreenCapture
			)
		)
		presentAsBottomSheet(viewController)
	}
	
	private func navigateToShowHints(hints: [String]) {
		let viewController = ShowHintsViewController(viewModel: ShowHintsViewModel(hints: hints, coordinator: self))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	private func navigateToEventDetails(_ title: String, details: [EventDetails], footer: String?) {
		
		let viewController = RemoteEventDetailsViewController(
			viewModel: RemoteEventDetailsViewModel(
				coordinator: self,
				title: title,
				details: details,
				footer: footer,
				hideBodyForScreenCapture: true
			)
		)
		presentAsBottomSheet(viewController)
	}

	@discardableResult private func navigateBackToEventStart() -> Bool {

		if let eventStartViewController = navigationController.viewControllers
			.first(where: { $0 is RemoteEventStartViewController }) {

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
				case is ListOptionsViewController:
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
	
	private func navigateBackToVisitorPassStart() -> Bool {
		
		if let eventStartViewController = navigationController.viewControllers
			.first(where: { $0 is VisitorPassStartViewController }) {
			
			navigationController.popToViewController(
				eventStartViewController,
				animated: true
			)
			return true
		}
		return false
	}

	private func displayError(content: Content, backAction: @escaping () -> Void) {

		let viewController = ContentViewController(
			viewModel: ContentViewModel(
				content: content,
				backAction: backAction,
				allowsSwipeBack: false
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}
}

extension EventCoordinator: EventCoordinatorDelegate {
	
	func showHintsScreenDidFinish(_ result: EventScreenResult) {
		delegate?.eventFlowDidComplete()
	}

	func eventStartScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case let .alternativeRoute(eventMode: eventMode): startAlternativeRoute(eventMode)
			case let .back(eventMode): handleBackAction(eventMode: eventMode)
			case .stop: delegate?.eventFlowDidCancel()
			case .backSwipe: delegate?.eventFlowDidCancelFromBackSwipe()
			case let .continue(eventMode): navigateToAuthentication(eventMode: eventMode)
			default: break
		}
	}

	private func handleBackAction(eventMode: EventMode) {

		delegate?.eventFlowDidCancel()
	}

	func authenticationScreenDidFinish(_ result: EventScreenResult) {

		switch result {

			case let .didLogin(token, authenticationMode, eventMode):
				navigateToFetchEvents(token: token, authenticationMode: authenticationMode, eventMode: eventMode)

			case let .errorRequiringRestart(eventMode, authenticationMode):
				handleErrorRequiringRestart(eventMode: eventMode, authenticationMode: authenticationMode)

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

			default:
				break
		}
	}

	private func goBack(_ eventMode: EventMode) {

		switch eventMode {
			case .vaccinationassessment:
				if !navigateBackToVisitorPassStart() {
					navigateBackToTestStart()
				}
			case .recovery, .vaccination, .vaccinationAndPositiveTest:
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
			case .stop:
				delegate?.eventFlowDidComplete()
			case .continue:
				delegate?.eventFlowDidComplete()
			case .back(let eventMode):
				goBack(eventMode)
			case let .error(content: content, backAction: backAction):
				displayError(content: content, backAction: backAction)
			case let .moreInformation(title, body, hideBodyForScreenCapture):
				navigateToMoreInformation(title, body: body, hideBodyForScreenCapture: hideBodyForScreenCapture)
			case let .showEventDetails(title, details, footer):
				navigateToEventDetails(title, details: details, footer: footer)
			case .shouldCompleteVaccinationAssessment:
				delegate?.eventFlowDidCompleteButVisitorPassNeedsCompletion()
			case let .showHints(hints):
				navigateToShowHints(hints: hints)
			default:
				break
		}
	}

	private func handleErrorRequiringRestart(eventMode: EventMode, authenticationMode: AuthenticationMode) {
		let popback = navigationController.viewControllers.first {
			// arrange `case`s in the order of matching priority
			switch $0 {
				case is RemoteEventStartViewController:
					return true
				case is ListOptionsViewController:
					return true
				default:
					return false
			}
		}

		let presentError = {
			let alertController = UIAlertController(
				title: {
					switch authenticationMode {
						case .manyAuthenticationExchange:
							return L.holder_authentication_popup_digid_title()
						case .patientAuthenticationProvider:
							return L.holder_authentication_popup_portal_title()
					}
				}(),
				message: {
					switch (eventMode, authenticationMode) {
						case (.vaccination, .manyAuthenticationExchange), (.vaccinationAndPositiveTest, .manyAuthenticationExchange):
							return L.holder_authentication_popup_digid_message_vaccinationFlow()
						case (_, .manyAuthenticationExchange):
							return L.holder_authentication_popup_digid_message_testFlow()
						case (.vaccination, .patientAuthenticationProvider), (.vaccinationAndPositiveTest, .patientAuthenticationProvider):
							return L.holder_authentication_popup_portal_message_vaccinationFlow()
						case (_, .patientAuthenticationProvider):
							return L.holder_authentication_popup_portal_message_testFlow()
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
	
	private func startAlternativeRoute(_ eventMode: EventMode) {
		
		startChildCoordinator(
			AlternativeRouteCoordinator(
				navigationController: navigationController,
				delegate: self,
				eventMode: eventMode
			)
		)
	}
}

extension EventCoordinator: AlternativeRouteFlowDelegate {
	
	func canceledAlternativeRoute() {
		
		guard let coordinator = childCoordinators.last, coordinator is AlternativeRouteCoordinator else { return }
		removeChildCoordinator(coordinator)
	}
	
	func backToMyOverview() {
		
		guard let coordinator = childCoordinators.last, coordinator is AlternativeRouteCoordinator else { return }
		removeChildCoordinator(coordinator)
		delegate?.eventFlowDidComplete()
	}
	
	func continueToPap(eventMode: EventMode) {
		
		guard let coordinator = childCoordinators.last, coordinator is AlternativeRouteCoordinator else { return }
		removeChildCoordinator(coordinator)
		navigateToAuthentication(eventMode: eventMode, authenticationMode: .patientAuthenticationProvider)
	}
}

extension EventCoordinator: Dismissable {

	func dismiss() {

		navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
	}
}

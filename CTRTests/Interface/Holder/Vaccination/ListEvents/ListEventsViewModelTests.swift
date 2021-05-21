/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
@testable import CTR
import XCTest
import Nimble

class ListEventsViewModelTests: XCTestCase {

	/// Subject under test
	var sut: ListEventsViewModel!
	var coordinatorSpy: VaccinationCoordinatorDelegateSpy!
	var walletSpy: WalletManagerSpy!

	override func setUp() {

		super.setUp()

		coordinatorSpy = VaccinationCoordinatorDelegateSpy()
		walletSpy = WalletManagerSpy()
		sut = ListEventsViewModel(coordinator: coordinatorSpy, remoteVaccinationEvents: [], walletManager: walletSpy)
	}

	func test_backButtonTapped_loadingState() {

		// Given
		sut.viewState = .loading(content: ListEventsViewController.Content(title: "test", subTitle: nil, primaryActionTitle: nil, primaryAction: nil, secondaryActionTitle: nil, secondaryAction: nil))

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.navigationAlert).toNot(beNil())
	}

	func test_backButtonTapped_emptyState() {

		// Given
		sut.viewState = .emptyEvents(content: ListEventsViewController.Content(title: "test", subTitle: nil, primaryActionTitle: nil, primaryAction: nil, secondaryActionTitle: nil, secondaryAction: nil))

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) == EventScreenResult.back
	}

	func test_backButtonTapped_listState() {

		// Given
		sut.viewState = .listEvents(content: ListEventsViewController.Content(title: "test", subTitle: nil, primaryActionTitle: nil, primaryAction: nil, secondaryActionTitle: nil, secondaryAction: nil), rows: [])

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.navigationAlert).toNot(beNil())
	}

	func test_warnBeforeGoBack() {

		// Given

		// When
		sut.warnBeforeGoBack()

		// Then
		expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == false
		expect(self.sut.navigationAlert).toNot(beNil())
	}

	func test_vaccinationrow_actionTapped() {

		// Given
		let remoteVaccinationEvent = RemoteVaccinationEvent(
			wrapper: Vaccination.EventResultWrapper(
				providerIdentifier: "CC",
				protocolVersion: "3.0",
				identity: identity,
				status: .complete,
				events: [
					Vaccination.Event(
						type: "vaccination",
						unique: "1234",
						vaccination: vaccinationEvent
					)
				]
			),
			signedResponse: signedResponse
		)
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			remoteVaccinationEvents: [remoteVaccinationEvent],
			walletManager: walletSpy
		)

		if case let .listEvents(content: _, rows: rows) = sut.viewState {

			// When
			rows.first?.action?()
			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) == .moreInformation(title: .holderVaccinationAboutTitle, body: .holderVaccinationAboutBody)
		} else {
			fail("wrong state")
		}
	}

	func test_somethingIsWrong_tapped() {

		// Given
		let remoteVaccinationEvent = RemoteVaccinationEvent(
			wrapper: Vaccination.EventResultWrapper(
				providerIdentifier: "CC",
				protocolVersion: "3.0",
				identity: identity,
				status: .complete,
				events: [
					Vaccination.Event(
						type: "vaccination",
						unique: "1234",
						vaccination: vaccinationEvent
					)
				]
			),
			signedResponse: signedResponse
		)
		sut = ListEventsViewModel(
			coordinator: coordinatorSpy,
			remoteVaccinationEvents: [remoteVaccinationEvent],
			walletManager: walletSpy
		)

		if case let .listEvents(content: content, rows: _) = sut.viewState {

			// When
			content.secondaryAction?()

			// Then
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinish) == true
			expect(self.coordinatorSpy.invokedListEventsScreenDidFinishParameters?.0) == .moreInformation(title: .holderVaccinationWrongTitle, body: .holderVaccinationWrongBody)
		} else {
			fail("wrong state")
		}
	}

	// MARK: Default values

	let identity = Vaccination.Identity(
		infix: "",
		firstName: "Corona",
		lastName: "Check",
		birthDateString: "2021-05-16"
	)

	let vaccinationEvent = Vaccination.VaccinationEvent(
		dateString: "2021-05-16",
		hpkCode: nil,
		type: nil,
		manufacturer: nil,
		brand: nil,
		completedByMedicalStatement: false,
		doseNumber: 1,
		totalDoses: 2
	)

	let signedResponse = SignedResponse(
		payload: "payload",
		signature: "signature"
	)
}

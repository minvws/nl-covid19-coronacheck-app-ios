/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR
import ViewControllerPresentationSpy

extension HolderCoordinatorTests {
	
	// MARK: - EventFlowDelegate -
	
	func test_eventFlowDidComplete() throws {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		sut.addChildCoordinator(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidComplete()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}

	func test_eventFlowDidCancel() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		sut.addChildCoordinator(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidCancel()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.invokedPopViewController) == false
	}
	
	// MARK: - PaperProofFlowDelegate -
	
	func test_addPaperProofFlowDidCancel() throws {
		
		// Given
		let (sut, _, _, _) = makeSUT()
		sut.addChildCoordinator(PaperProofCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.addPaperProofFlowDidCancel()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_addPaperProofFlowDidFinish() throws {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		sut.addChildCoordinator(PaperProofCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.addPaperProofFlowDidFinish()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}
	
	func test_switchToAddRegularProof() throws {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		sut.addChildCoordinator(PaperProofCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.switchToAddRegularProof()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.pushViewControllerCallCount) == 1
		expect(navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseProofTypeViewModel.self))
	}
	
	func test_handleMismatchedIdentityError() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		
		// When
		sut.handleMismatchedIdentityError(matchingBlobIds: [["123"]])
		
		// Then
		expect(sut.childCoordinators).to(haveCount(1))
		expect(sut.childCoordinators.first).to(beAKindOf(FuzzyMatchingCoordinator.self))
		expect(navigationSpy.viewControllers.last is PagedAnnouncementViewController) == true
	}
	
	func test_fuzzyMatchingFlowDidStop() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		let fmCoordinator = FuzzyMatchingCoordinator(
			navigationController: sut.navigationController,
			matchingBlobIds: [[]],
			onboardingFactory: FuzzyMatchingOnboardingFactory(),
			delegate: sut
		)
		sut.childCoordinators = [fmCoordinator]
		
		// When
		fmCoordinator.userHasStoppedTheFlow()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.invokedPopToRootViewController) == true
	}
	
	func test_fuzzyMatchingFlowDidFinish() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		let fmCoordinator = FuzzyMatchingCoordinator(
			navigationController: sut.navigationController,
			matchingBlobIds: [[]],
			onboardingFactory: FuzzyMatchingOnboardingFactory(),
			delegate: sut
		)
		sut.childCoordinators = [fmCoordinator]
		
		// When
		fmCoordinator.userHasFinishedTheFlow()
		
		// Then
		expect(navigationSpy.invokedPopToRootViewController) == true
	}
	
	// MARK: - MigrationFlowDelegate -
	
	func test_dataMigrationBackAction() {
		
		// Given
		let (sut, _, _, _) = makeSUT()
		sut.childCoordinators = [MigrationCoordinator(navigationController: sut.navigationController, delegate: sut)]
		
		// When
		sut.dataMigrationBackAction()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_dataMigrationCancelled() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		sut.childCoordinators = [MigrationCoordinator(navigationController: sut.navigationController, delegate: sut)]
		
		// When
		sut.dataMigrationCancelled()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}
	
	func test_dataMigrationExportCompleted() {
		
		// Given
		let (sut, navigationSpy, alertVerifier, _) = makeSUT()
		sut.childCoordinators = [MigrationCoordinator(navigationController: sut.navigationController, delegate: sut)]
		
		// When
		sut.dataMigrationExportCompleted()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.viewControllers.last is HolderDashboardViewController) == true
		expect(alertVerifier.presentedCount).toEventually(equal(1))
		
	}
	
	func test_dataMigrationImportCompleted() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		sut.childCoordinators = [MigrationCoordinator(navigationController: sut.navigationController, delegate: sut)]
		
		// When
		sut.dataMigrationImportCompleted()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}
	
	// MARK: - PDFExportFlowDelegate
	
	func test_pdfExport_completed() {
		
		// Given
		let (sut, _, _, _) = makeSUT()
		sut.childCoordinators = [
			PDFExportCoordinator(
				navigationController: sut.navigationController,
				delegate: sut
			)
		]
		
		// When
		sut.exportCompleted()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_pdfExport_failed() {
		
		// Given
		let (sut, _, _, _) = makeSUT()
		sut.childCoordinators = [
			PDFExportCoordinator(
				navigationController: sut.navigationController,
				delegate: sut
			)
		]
		
		// When
		sut.exportFailed()
		
		// Then
		expect(sut.childCoordinators).to(beEmpty())
	}
}

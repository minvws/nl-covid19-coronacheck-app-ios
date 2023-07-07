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
		sut.addChildCoordinator(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidComplete()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}

	func test_eventFlowDidCancel() {
		
		// Given
		sut.addChildCoordinator(EventCoordinator(navigationController: sut.navigationController, delegate: sut))
		
		// When
		sut.eventFlowDidCancel()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.invokedPopViewController) == false
	}
	
	// MARK: - PaperProofFlowDelegate -
	
	func test_addPaperProofFlowDidCancel() throws {
		
		// Given
		sut.addChildCoordinator(PaperProofCoordinator(navigationController: navigationSpy, delegate: sut))
		
		// When
		sut.addPaperProofFlowDidCancel()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_addPaperProofFlowDidFinish() throws {
		
		// Given
		sut.addChildCoordinator(PaperProofCoordinator(navigationController: navigationSpy, delegate: sut))
		
		// When
		sut.addPaperProofFlowDidFinish()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}
	
	func test_switchToAddRegularProof() throws {
		
		// Given
		sut.addChildCoordinator(PaperProofCoordinator(navigationController: navigationSpy, delegate: sut))
		
		// When
		sut.switchToAddRegularProof()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.pushViewControllerCallCount) == 1
		expect(self.navigationSpy.viewControllers.last is ListOptionsViewController) == true
		expect((self.navigationSpy.viewControllers.last as? ListOptionsViewController)?.viewModel).to(beAnInstanceOf(ChooseProofTypeViewModel.self))
	}
	
	func test_handleMismatchedIdentityError() {
		
		// Given
		
		// When
		sut.handleMismatchedIdentityError(matchingBlobIds: [["123"]])
		
		// Then
		expect(self.sut.childCoordinators).to(haveCount(1))
		expect(self.sut.childCoordinators.first).to(beAKindOf(FuzzyMatchingCoordinator.self))
		expect(self.navigationSpy.viewControllers.last is PagedAnnouncementViewController) == true
	}
	
	func test_fuzzyMatchingFlowDidStop() {
		
		// Given
		
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
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.invokedPopToRootViewController) == true
	}
	
	func test_fuzzyMatchingFlowDidFinish() {
		
		// Given
		
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
		expect(self.navigationSpy.invokedPopToRootViewController) == true
	}
	
	// MARK: - MigrationFlowDelegate -
	
	func test_dataMigrationBackAction() {
		
		// Given
		sut.childCoordinators = [MigrationCoordinator(navigationController: navigationSpy, delegate: sut)]
		
		// When
		sut.dataMigrationBackAction()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_dataMigrationCancelled() {
		
		// Given
		sut.childCoordinators = [MigrationCoordinator(navigationController: navigationSpy, delegate: sut)]
		
		// When
		sut.dataMigrationCancelled()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}
	
	func test_dataMigrationExportCompleted() {
		
		// Given
		sut.childCoordinators = [MigrationCoordinator(navigationController: navigationSpy, delegate: sut)]
		
		// When
		sut.dataMigrationExportCompleted()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.viewControllers.last is HolderDashboardViewController) == true
		expect(self.alertVerifier?.presentedCount).toEventually(equal(1))
		
	}
	
	func test_dataMigrationImportCompleted() {
		
		// Given
		sut.childCoordinators = [MigrationCoordinator(navigationController: navigationSpy, delegate: sut)]
		
		// When
		sut.dataMigrationImportCompleted()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
		expect(self.navigationSpy.viewControllers.last is HolderDashboardViewController) == true
	}
	
	// MARK: - PDFExportFlowDelegate
	
	func test_pdfExport_completed() {
		
		// Given
		sut.childCoordinators = [
			PDFExportCoordinator(
				navigationController: navigationSpy,
				delegate: sut
			)
		]
		
		// When
		sut.exportCompleted()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
	}
	
	func test_pdfExport_failed() {
		
		// Given
		sut.childCoordinators = [
			PDFExportCoordinator(
				navigationController: navigationSpy,
				delegate: sut
			)
		]
		
		// When
		sut.exportFailed()
		
		// Then
		expect(self.sut.childCoordinators).to(beEmpty())
	}
}

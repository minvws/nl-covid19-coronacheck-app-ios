/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoreData
import XCTest
@testable import CTR
import ReusableViews
import TestingShared
import Persistence
@testable import Transport
@testable import Models

class HolderCoordinatorDelegateSpy: HolderCoordinatorDelegate, Dismissable, OpenUrlProtocol {

	var invokedNavigateBackToStart = false
	var invokedNavigateBackToStartCount = 0

	func navigateBackToStart() {
		invokedNavigateBackToStart = true
		invokedNavigateBackToStartCount += 1
	}

	var invokedHandleMismatchedIdentityError = false
	var invokedHandleMismatchedIdentityErrorCount = 0
	var invokedHandleMismatchedIdentityErrorParameters: (matchingBlobIds: [[String]], Void)?
	var invokedHandleMismatchedIdentityErrorParametersList = [(matchingBlobIds: [[String]], Void)]()

	func handleMismatchedIdentityError(matchingBlobIds: [[String]]) {
		invokedHandleMismatchedIdentityError = true
		invokedHandleMismatchedIdentityErrorCount += 1
		invokedHandleMismatchedIdentityErrorParameters = (matchingBlobIds, ())
		invokedHandleMismatchedIdentityErrorParametersList.append((matchingBlobIds, ()))
	}

	var invokedOpenUrl = false
	var invokedOpenUrlCount = 0
	var invokedOpenUrlParameters: (url: URL, Void)?
	var invokedOpenUrlParametersList = [(url: URL, Void)]()

	func openUrl(_ url: URL) {
		invokedOpenUrl = true
		invokedOpenUrlCount += 1
		invokedOpenUrlParameters = (url, ())
		invokedOpenUrlParametersList.append((url, ()))
	}

	var invokedPresentError = false
	var invokedPresentErrorCount = 0
	var invokedPresentErrorParameters: (content: Content, Void)?
	var invokedPresentErrorParametersList = [(content: Content, Void)]()
	var shouldInvokePresentErrorBackAction = false

	func presentError(content: Content, backAction: (() -> Void)?) {
		invokedPresentError = true
		invokedPresentErrorCount += 1
		invokedPresentErrorParameters = (content, ())
		invokedPresentErrorParametersList.append((content, ()))
		if shouldInvokePresentErrorBackAction {
			backAction?()
		}
	}

	var invokedPresentInformationPage = false
	var invokedPresentInformationPageCount = 0
	var invokedPresentInformationPageParameters: (title: String, body: String, hideBodyForScreenCapture: Bool)?
	var invokedPresentInformationPageParametersList = [(title: String, body: String, hideBodyForScreenCapture: Bool)]()

	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool) {
		invokedPresentInformationPage = true
		invokedPresentInformationPageCount += 1
		invokedPresentInformationPageParameters = (title, body, hideBodyForScreenCapture)
		invokedPresentInformationPageParametersList.append((title, body, hideBodyForScreenCapture))
	}

	var invokedPresentDCCQRDetails = false
	var invokedPresentDCCQRDetailsCount = 0
	var invokedPresentDCCQRDetailsParameters: (title: String, description: String, details: [DCCQRDetails], dateInformation: String)?
	var invokedPresentDCCQRDetailsParametersList = [(title: String, description: String, details: [DCCQRDetails], dateInformation: String)]()

	func presentDCCQRDetails(title: String, description: String, details: [DCCQRDetails], dateInformation: String) {
		invokedPresentDCCQRDetails = true
		invokedPresentDCCQRDetailsCount += 1
		invokedPresentDCCQRDetailsParameters = (title, description, details, dateInformation)
		invokedPresentDCCQRDetailsParametersList.append((title, description, details, dateInformation))
	}

	var invokedUserWishesMoreInfoAboutBlockedEventsBeingDeleted = false
	var invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedCount = 0
	var invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedParameters: (blockedEventItems: [RemovedEventItem], Void)?
	var invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedParametersList = [(blockedEventItems: [RemovedEventItem], Void)]()

	func userWishesMoreInfoAboutBlockedEventsBeingDeleted(blockedEventItems: [RemovedEventItem]) {
		invokedUserWishesMoreInfoAboutBlockedEventsBeingDeleted = true
		invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedCount += 1
		invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedParameters = (blockedEventItems, ())
		invokedUserWishesMoreInfoAboutBlockedEventsBeingDeletedParametersList.append((blockedEventItems, ()))
	}

	var invokedUserWishesMoreInfoAboutClockDeviation = false
	var invokedUserWishesMoreInfoAboutClockDeviationCount = 0

	func userWishesMoreInfoAboutClockDeviation() {
		invokedUserWishesMoreInfoAboutClockDeviation = true
		invokedUserWishesMoreInfoAboutClockDeviationCount += 1
	}

	var invokedUserWishesMoreInfoAboutCompletingVaccinationAssessment = false
	var invokedUserWishesMoreInfoAboutCompletingVaccinationAssessmentCount = 0

	func userWishesMoreInfoAboutCompletingVaccinationAssessment() {
		invokedUserWishesMoreInfoAboutCompletingVaccinationAssessment = true
		invokedUserWishesMoreInfoAboutCompletingVaccinationAssessmentCount += 1
	}

	var invokedUserWishesMoreInfoAboutExpiredDomesticVaccination = false
	var invokedUserWishesMoreInfoAboutExpiredDomesticVaccinationCount = 0

	func userWishesMoreInfoAboutExpiredDomesticVaccination() {
		invokedUserWishesMoreInfoAboutExpiredDomesticVaccination = true
		invokedUserWishesMoreInfoAboutExpiredDomesticVaccinationCount += 1
	}

	var invokedUserWishesMoreInfoAboutExpiredQR = false
	var invokedUserWishesMoreInfoAboutExpiredQRCount = 0

	func userWishesMoreInfoAboutExpiredQR() {
		invokedUserWishesMoreInfoAboutExpiredQR = true
		invokedUserWishesMoreInfoAboutExpiredQRCount += 1
	}

	var invokedUserWishesMoreInfoAboutHiddenQR = false
	var invokedUserWishesMoreInfoAboutHiddenQRCount = 0

	func userWishesMoreInfoAboutHiddenQR() {
		invokedUserWishesMoreInfoAboutHiddenQR = true
		invokedUserWishesMoreInfoAboutHiddenQRCount += 1
	}

	var invokedUserWishesMoreInfoAboutGettingTested = false
	var invokedUserWishesMoreInfoAboutGettingTestedCount = 0

	func userWishesMoreInfoAboutGettingTested() {
		invokedUserWishesMoreInfoAboutGettingTested = true
		invokedUserWishesMoreInfoAboutGettingTestedCount += 1
	}

	var invokedUserWishesMoreInfoAboutMismatchedIdentityEventsBeingDeleted = false
	var invokedUserWishesMoreInfoAboutMismatchedIdentityEventsBeingDeletedCount = 0
	var invokedUserWishesMoreInfoAboutMismatchedIdentityEventsBeingDeletedParameters: (items: [RemovedEventItem], Void)?
	var invokedUserWishesMoreInfoAboutMismatchedIdentityEventsBeingDeletedParametersList = [(items: [RemovedEventItem], Void)]()

	func userWishesMoreInfoAboutMismatchedIdentityEventsBeingDeleted(items: [RemovedEventItem]) {
		invokedUserWishesMoreInfoAboutMismatchedIdentityEventsBeingDeleted = true
		invokedUserWishesMoreInfoAboutMismatchedIdentityEventsBeingDeletedCount += 1
		invokedUserWishesMoreInfoAboutMismatchedIdentityEventsBeingDeletedParameters = (items, ())
		invokedUserWishesMoreInfoAboutMismatchedIdentityEventsBeingDeletedParametersList.append((items, ()))
	}

	var invokedUserWishesMoreInfoAboutNoTestToken = false
	var invokedUserWishesMoreInfoAboutNoTestTokenCount = 0

	func userWishesMoreInfoAboutNoTestToken() {
		invokedUserWishesMoreInfoAboutNoTestToken = true
		invokedUserWishesMoreInfoAboutNoTestTokenCount += 1
	}

	var invokedUserWishesMoreInfoAboutNoVisitorPassToken = false
	var invokedUserWishesMoreInfoAboutNoVisitorPassTokenCount = 0

	func userWishesMoreInfoAboutNoVisitorPassToken() {
		invokedUserWishesMoreInfoAboutNoVisitorPassToken = true
		invokedUserWishesMoreInfoAboutNoVisitorPassTokenCount += 1
	}

	var invokedUserWishesMoreInfoAboutOutdatedConfig = false
	var invokedUserWishesMoreInfoAboutOutdatedConfigCount = 0
	var invokedUserWishesMoreInfoAboutOutdatedConfigParameters: (validUntil: String, Void)?
	var invokedUserWishesMoreInfoAboutOutdatedConfigParametersList = [(validUntil: String, Void)]()

	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String) {
		invokedUserWishesMoreInfoAboutOutdatedConfig = true
		invokedUserWishesMoreInfoAboutOutdatedConfigCount += 1
		invokedUserWishesMoreInfoAboutOutdatedConfigParameters = (validUntil, ())
		invokedUserWishesMoreInfoAboutOutdatedConfigParametersList.append((validUntil, ()))
	}

	var invokedUserWishesMoreInfoAboutUnavailableQR = false
	var invokedUserWishesMoreInfoAboutUnavailableQRCount = 0
	var invokedUserWishesMoreInfoAboutUnavailableQRParameters: (originType: OriginType, currentRegion: QRCodeValidityRegion)?
	var invokedUserWishesMoreInfoAboutUnavailableQRParametersList = [(originType: OriginType, currentRegion: QRCodeValidityRegion)]()

	func userWishesMoreInfoAboutUnavailableQR(originType: OriginType, currentRegion: QRCodeValidityRegion) {
		invokedUserWishesMoreInfoAboutUnavailableQR = true
		invokedUserWishesMoreInfoAboutUnavailableQRCount += 1
		invokedUserWishesMoreInfoAboutUnavailableQRParameters = (originType, currentRegion)
		invokedUserWishesMoreInfoAboutUnavailableQRParametersList.append((originType, currentRegion))
	}

	var invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL = false
	var invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNLCount = 0

	func userWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL() {
		invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL = true
		invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNLCount += 1
	}

	var invokedUserWishesToAddPaperProof = false
	var invokedUserWishesToAddPaperProofCount = 0

	func userWishesToAddPaperProof() {
		invokedUserWishesToAddPaperProof = true
		invokedUserWishesToAddPaperProofCount += 1
	}

	var invokedUserWishesToAddVisitorPass = false
	var invokedUserWishesToAddVisitorPassCount = 0

	func userWishesToAddVisitorPass() {
		invokedUserWishesToAddVisitorPass = true
		invokedUserWishesToAddVisitorPassCount += 1
	}

	var invokedUserWishesToChooseTestLocation = false
	var invokedUserWishesToChooseTestLocationCount = 0

	func userWishesToChooseTestLocation() {
		invokedUserWishesToChooseTestLocation = true
		invokedUserWishesToChooseTestLocationCount += 1
	}

	var invokedUserWishesToCreateANegativeTestQR = false
	var invokedUserWishesToCreateANegativeTestQRCount = 0

	func userWishesToCreateANegativeTestQR() {
		invokedUserWishesToCreateANegativeTestQR = true
		invokedUserWishesToCreateANegativeTestQRCount += 1
	}

	var invokedUserWishesToCreateANegativeTestQRFromGGD = false
	var invokedUserWishesToCreateANegativeTestQRFromGGDCount = 0

	func userWishesToCreateANegativeTestQRFromGGD() {
		invokedUserWishesToCreateANegativeTestQRFromGGD = true
		invokedUserWishesToCreateANegativeTestQRFromGGDCount += 1
	}

	var invokedUserWishesToCreateAQR = false
	var invokedUserWishesToCreateAQRCount = 0

	func userWishesToCreateAQR() {
		invokedUserWishesToCreateAQR = true
		invokedUserWishesToCreateAQRCount += 1
	}

	var invokedUserWishesToCreateARecoveryQR = false
	var invokedUserWishesToCreateARecoveryQRCount = 0

	func userWishesToCreateARecoveryQR() {
		invokedUserWishesToCreateARecoveryQR = true
		invokedUserWishesToCreateARecoveryQRCount += 1
	}

	var invokedUserWishesToCreateAVaccinationQR = false
	var invokedUserWishesToCreateAVaccinationQRCount = 0

	func userWishesToCreateAVaccinationQR() {
		invokedUserWishesToCreateAVaccinationQR = true
		invokedUserWishesToCreateAVaccinationQRCount += 1
	}

	var invokedUserWishesToCreateAVisitorPass = false
	var invokedUserWishesToCreateAVisitorPassCount = 0

	func userWishesToCreateAVisitorPass() {
		invokedUserWishesToCreateAVisitorPass = true
		invokedUserWishesToCreateAVisitorPassCount += 1
	}

	var invokedUserWishesToLaunchThirdPartyTicketApp = false
	var invokedUserWishesToLaunchThirdPartyTicketAppCount = 0

	func userWishesToLaunchThirdPartyTicketApp() {
		invokedUserWishesToLaunchThirdPartyTicketApp = true
		invokedUserWishesToLaunchThirdPartyTicketAppCount += 1
	}

	var invokedUserWishesToMakeQRFromRemoteEvent = false
	var invokedUserWishesToMakeQRFromRemoteEventCount = 0
	var invokedUserWishesToMakeQRFromRemoteEventParameters: (remoteEvent: RemoteEvent, originalMode: EventMode)?
	var invokedUserWishesToMakeQRFromRemoteEventParametersList = [(remoteEvent: RemoteEvent, originalMode: EventMode)]()

	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent, originalMode: EventMode) {
		invokedUserWishesToMakeQRFromRemoteEvent = true
		invokedUserWishesToMakeQRFromRemoteEventCount += 1
		invokedUserWishesToMakeQRFromRemoteEventParameters = (remoteEvent, originalMode)
		invokedUserWishesToMakeQRFromRemoteEventParametersList.append((remoteEvent, originalMode))
	}

	var invokedUserWishesToOpenTheMenu = false
	var invokedUserWishesToOpenTheMenuCount = 0

	func userWishesToOpenTheMenu() {
		invokedUserWishesToOpenTheMenu = true
		invokedUserWishesToOpenTheMenuCount += 1
	}

	var invokedUserWishesToRestart = false
	var invokedUserWishesToRestartCount = 0

	func userWishesToRestart() {
		invokedUserWishesToRestart = true
		invokedUserWishesToRestartCount += 1
	}

	var invokedUserWishesToSeeAboutThisApp = false
	var invokedUserWishesToSeeAboutThisAppCount = 0

	func userWishesToSeeAboutThisApp() {
		invokedUserWishesToSeeAboutThisApp = true
		invokedUserWishesToSeeAboutThisAppCount += 1
	}

	var invokedUserWishesToSeeEventDetails = false
	var invokedUserWishesToSeeEventDetailsCount = 0
	var invokedUserWishesToSeeEventDetailsParameters: (title: String, details: [EventDetails])?
	var invokedUserWishesToSeeEventDetailsParametersList = [(title: String, details: [EventDetails])]()

	func userWishesToSeeEventDetails(_ title: String, details: [EventDetails]) {
		invokedUserWishesToSeeEventDetails = true
		invokedUserWishesToSeeEventDetailsCount += 1
		invokedUserWishesToSeeEventDetailsParameters = (title, details)
		invokedUserWishesToSeeEventDetailsParametersList.append((title, details))
	}

	var invokedUserWishesToSeeHelpAndInfoMenu = false
	var invokedUserWishesToSeeHelpAndInfoMenuCount = 0

	func userWishesToSeeHelpAndInfoMenu() {
		invokedUserWishesToSeeHelpAndInfoMenu = true
		invokedUserWishesToSeeHelpAndInfoMenuCount += 1
	}

	var invokedUserWishesToSeeHelpdesk = false
	var invokedUserWishesToSeeHelpdeskCount = 0

	func userWishesToSeeHelpdesk() {
		invokedUserWishesToSeeHelpdesk = true
		invokedUserWishesToSeeHelpdeskCount += 1
	}

	var invokedUserWishesToSeeStoredEvents = false
	var invokedUserWishesToSeeStoredEventsCount = 0

	func userWishesToSeeStoredEvents() {
		invokedUserWishesToSeeStoredEvents = true
		invokedUserWishesToSeeStoredEventsCount += 1
	}

	var invokedUserWishesToViewQRs = false
	var invokedUserWishesToViewQRsCount = 0
	var invokedUserWishesToViewQRsParameters: (greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?)?
	var invokedUserWishesToViewQRsParametersList = [(greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?)]()

	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?) {
		invokedUserWishesToViewQRs = true
		invokedUserWishesToViewQRsCount += 1
		invokedUserWishesToViewQRsParameters = (greenCardObjectIDs, disclosurePolicy)
		invokedUserWishesToViewQRsParametersList.append((greenCardObjectIDs, disclosurePolicy))
	}

	var invokedDismiss = false
	var invokedDismissCount = 0

	func dismiss() {
		invokedDismiss = true
		invokedDismissCount += 1
	}
}

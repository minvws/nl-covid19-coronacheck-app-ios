/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Transport

class SendIdentitySelectionViewModel {
	
	let title = Observable<String>(value: L.holder_identitySelection_loading_title())
	let showSpinner = Observable<Bool>(value: true)
	var alert: Observable<AlertContent?> = Observable(value: nil)

	private var selectedBlobIds = [String]()
	private var matchingBlobIds = [[String]]()
	private var selectedIdentity: String? {
		get {
			return Current.secureUserSettings.selectedIdentity
		}
		set {
			Current.secureUserSettings.selectedIdentity = newValue
		}
	}
	
	weak private var coordinatorDelegate: FuzzyMatchingCoordinatorDelegate?
	
	private var dataSource: IdentitySelectionDataSourceProtocol!
	
	init(
		coordinatorDelegate: FuzzyMatchingCoordinatorDelegate,
		dataSource: IdentitySelectionDataSourceProtocol,
		matchingBlobIds: [[String]],
		selectedBlobIds: [String]) {
		
		self.coordinatorDelegate = coordinatorDelegate
		self.dataSource = dataSource
		self.matchingBlobIds = matchingBlobIds
		self.selectedBlobIds = selectedBlobIds
	}
	
	func viewDidAppear() {
		
		guard matchingBlobIds.count > 1, selectedBlobIds.isNotEmpty else {
			displayErrorCode(ErrorCode(flow: .fuzzyMatching, step: .removeEventGroups, clientCode: .noSelectionMade))
			return
		}
		
		guard persistSelectedIdentity() else {
			displayErrorCode(ErrorCode(flow: .fuzzyMatching, step: .removeEventGroups, clientCode: .failedToPersistIdentity))
			return
		}
		
		guard persistAndRemoveEventGroups() else {
			selectedIdentity = nil
			displayErrorCode(ErrorCode(flow: .fuzzyMatching, step: .removeEventGroups, clientCode: .failedToRemoveEventGroups))
			return
		}

		sendEventsToTheSigner()
	}
	
	private func persistSelectedIdentity() -> Bool {
		
		if let primaryId = selectedBlobIds.first {
			selectedIdentity = dataSource.getIdentity(primaryId)?.fullName
		} else {
			selectedIdentity = nil
		}
		return selectedIdentity != nil
	}
	
	private func persistAndRemoveEventGroups() -> Bool {
		
		var result = true
		
		matchingBlobIds.forEach { blobIds in
			if selectedBlobIds != blobIds {
				blobIds.forEach { uniqueIdentifier in
					if let wrapper = dataSource.getEventResultWrapper(uniqueIdentifier) {
						result = result && RemovedEvent.createAndPersist(wrapper: wrapper, reason: RemovalReason.mismatchedIdentity).isNotEmpty
					} else if let euCredentialAttributes = dataSource.getEUCreditialAttributes(uniqueIdentifier) {
						result = result && RemovedEvent.createAndPersist(euCredentialAttributes: euCredentialAttributes, reason: RemovalReason.mismatchedIdentity) != nil
					}
					
					let eventGroups = Current.walletManager.listEventGroups()
					if let eventGroup = eventGroups.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
						logVerbose("SendIdentitySelectionViewModel - removing eventGroup: \(eventGroup.objectID)")
						result = result && Current.dataStoreManager.delete(eventGroup.objectID).isSuccess
					}
				}
			}
		}
		return result
	}
	
	private func sendEventsToTheSigner() {
		
		Current.greenCardLoader.signTheEventsIntoGreenCardsAndCredentials(eventMode: nil) { [weak self] result in
			// Result<RemoteGreenCards.Response, Error>
			
			guard let self else { return }
			switch result {
				case .success:
					self.coordinatorDelegate?.userWishesToSeeSuccess(name: self.selectedIdentity ?? "")
					
				case let .failure(greenCardError):
					let parser = GreenCardResponseErrorParser(flow: ErrorCode.Flow.fuzzyMatching)
					switch parser.parse(greenCardError) {
						case .noInternet:
							self.displayNoInternet()
						case .noSignedEvents:
							self.displayErrorCode(ErrorCode(flow: .fuzzyMatching, step: .signer, clientCode: .noEventsToSendToTheSigner))
						case let .customError(title: title, message: message):
							self.displayError(title: title, message: message)
						case let .mismatchedIdentity(matchingBlobIds: matchingBlobIds):
							self.coordinatorDelegate?.restartFlow(matchingBlobIds: matchingBlobIds)
					}
			}
		}
	}
	
	func displayNoInternet() {
		
		alert.value = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			okAction: AlertContent.Action(
				title: L.generalRetry(),
				action: { [weak self] _ in
					self?.sendEventsToTheSigner()
				},
				isPreferred: true
			),
			cancelAction: AlertContent.Action(
				title: L.generalClose(),
				action: { [weak self] _ in
					guard let self = self else { return }
					self.coordinatorDelegate?.userHasStoppedTheFlow()
				}
			)
		)
	}
	
	func displayErrorCode(_ errorCode: ErrorCode) {
		
		self.displayError(
			title: L.holderErrorstateTitle(),
			message: L.holderErrorstateClientMessage("\(errorCode)")
		)
		return
		
	}
	
	func displayError(title: String, message: String) {
		
		let content = Content(
			title: title,
			body: message,
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: {[weak self] in
				self?.coordinatorDelegate?.userHasStoppedTheFlow()
			}
		)
		DispatchQueue.main.asyncAfter(deadline: .now() + (ProcessInfo().isUnitTesting ? 0 : 0.5)) {
			self.coordinatorDelegate?.presentError(content: content, backAction: nil)
		}
	}
}

// MARK: - ErrorCode.Flow

extension ErrorCode.Flow {

	static let fuzzyMatching = ErrorCode.Flow(value: "13")
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {
	
	static let noEventsToSendToTheSigner = ErrorCode.ClientCode(value: "100")
	static let noSelectionMade = ErrorCode.ClientCode(value: "101")
	static let failedToPersistIdentity = ErrorCode.ClientCode(value: "102")
	static let failedToRemoveEventGroups = ErrorCode.ClientCode(value: "103")
}

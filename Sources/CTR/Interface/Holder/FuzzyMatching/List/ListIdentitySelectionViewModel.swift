/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Shared
import Transport

enum IdentityControlViewState {
	case selected
	case unselected
	case selectionError
	case warning(String)
}

class IdentityItem {
	 
	init(blobIds: [String], name: String, eventCountInformation: String, onShowDetails: @escaping () -> Void, onSelectIdentity: @escaping () -> Void, state: Observable<IdentityControlViewState>) {
		self.blobIds = blobIds
		self.name = name
		self.eventCountInformation = eventCountInformation
		self.onShowDetails = onShowDetails
		self.onSelectIdentity = onSelectIdentity
		self.state = state
	}
	
	var blobIds: [String]
	var name: String
	var eventCountInformation: String
	var onShowDetails: () -> Void
	var onSelectIdentity: () -> Void
	var state: Observable<IdentityControlViewState>
}

class ListIdentitySelectionViewModel {
	
	// Observable variables
	let title = Observable<String>(value: L.holder_identitySelection_title())
	let message = Observable<String>(value: L.holder_identitySelection_message())
	let whyTitle = Observable<String>(value: L.holder_identitySelection_why())
	let actionTitle = Observable<String>(value: L.holder_identitySelection_actionTitle())
	var errorMessage = Observable<String?>(value: nil)
	var identityItems = Observable<[IdentityItem]>(value: [])
	var alert: Observable<AlertContent?> = Observable(value: nil)
	
	private var selectedBlobIds = [String]()
	private var nestedBlobIds = [[String]]()
	
	weak private var coordinatorDelegate: FuzzyMatchingCoordinatorDelegate?
	
	private var dataSource: IdentitySelectionDataSourceProtocol!
	
	init(
		coordinatorDelegate: FuzzyMatchingCoordinatorDelegate,
		dataSource: IdentitySelectionDataSourceProtocol,
		nestedBlobIds: [[String]]) {
		
		self.coordinatorDelegate = coordinatorDelegate
		self.dataSource = dataSource
		self.nestedBlobIds = nestedBlobIds
		self.populateIdentityObjects()
	}
	
	private func populateIdentityObjects() {
		
		var items = [IdentityItem]()
		
		let tuples = dataSource.getIdentityInformation(nestedBlobIds: nestedBlobIds)
		for identity in tuples {
			let object = IdentityItem(
				blobIds: identity.blobIds,
				name: identity.name,
				eventCountInformation: identity.eventCountInformation,
				onShowDetails: { [weak self] in
					self?.coordinatorDelegate?.userWishesToSeeIdentitySelectionDetails(
						IdentitySelectionDetails(
							name: identity.name,
							details: self?.dataSource.getEventOveriew(blobIds: identity.blobIds) ?? [[]]
						)
					)
				},
				onSelectIdentity: { [weak self] in
					self?.onSelectIdentity(identity.blobIds)
				},
				state: Observable<IdentityControlViewState>(value: .unselected)
			)
			items.append(object)
		}
		identityItems.value = items
	}
	
	private func onSelectIdentity(_ blobIds: [String]) {
		
		self.selectedBlobIds = blobIds
		identityItems.value.forEach {
			if $0.blobIds == blobIds {
				$0.state.value = .selected
			} else {
				$0.state.value = .warning(L.holder_identitySelection_error_willBeRemoved())
			}
		}
		
		errorMessage.value = nil
	}
	
	func userWishedToReadMore() {
		
		coordinatorDelegate?.userWishesMoreInfoAboutWhy()
	}
	
	func userWishesToSaveEvents() {
		
		logInfo("userWishesToSaveEvents")
		
		guard selectedBlobIds.isNotEmpty else {
		
			identityItems.value.forEach { $0.state.value = .selectionError }
			errorMessage.value = L.holder_identitySelection_error_makeAChoice()
			return
		}
		
		persistAndRemoveEventGroups()
		coordinatorDelegate?.userHasFinishedTheFlow()
	}
	
	private func persistAndRemoveEventGroups() {
		
		nestedBlobIds.forEach { blobIds in
			if selectedBlobIds != blobIds {
				blobIds.forEach { uniqueIdentifier in
					if let wrapper = dataSource.cache.getEventResultWrapper(uniqueIdentifier) {
						RemovedEvent.createAndPersist(wrapper: wrapper, reason: RemovedEventModel.identityMismatch)
					} else if let euCredentialAttributes = dataSource.cache.getEUCreditialAttributes(uniqueIdentifier) {
						RemovedEvent.createAndPersist(euCredentialAttributes: euCredentialAttributes, reason: RemovedEventModel.identityMismatch)
					}
					
					let eventGroups = Current.walletManager.listEventGroups()
					if let eventGroup = eventGroups.first(where: { $0.uniqueIdentifier == uniqueIdentifier }) {
						logInfo("ABOUT TO REMOVE \(eventGroup.objectID)")
						Current.dataStoreManager.delete(eventGroup.objectID)
					}
				}
			}
		}
	}
	
	func userWishesToSkip() {
		
		alert.value = AlertContent(
			title: L.holder_identitySelection_skipAlert_title(),
			subTitle: L.holder_identitySelection_skipAlert_body(),
			okAction: AlertContent.Action(title: L.holder_identitySelection_skipAlert_action(), action: { _ in
				self.coordinatorDelegate?.userHasFinishedTheFlow()
			}, isDestructive: true),
			cancelAction: AlertContent.Action(title: L.general_cancel())
		)
	}
}

/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Shared
import ReusableViews
import Transport
import Resources

enum IdentityControlViewState: Equatable {
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
	var showSkipButton = Observable<Bool>(value: true)
	
	internal var selectedBlobIds = [String]()
	internal var matchingBlobIds = [[String]]()
	
	weak private var coordinatorDelegate: FuzzyMatchingCoordinatorDelegate?
	
	private var dataSource: IdentitySelectionDataSourceProtocol!
	
	init(
		coordinatorDelegate: FuzzyMatchingCoordinatorDelegate,
		dataSource: IdentitySelectionDataSourceProtocol,
		matchingBlobIds: [[String]],
		date: Date = Current.now(),
		shouldHideSkipButton: Bool = false) {
		
		self.coordinatorDelegate = coordinatorDelegate
		self.dataSource = dataSource
		self.matchingBlobIds = matchingBlobIds
		self.populateIdentityObjects()
		
		self.showSkipButton.value = {
			
			// US 4985: Hide skip button in add event flow
			guard !shouldHideSkipButton else {
				return false
			}
			
			// US 4958: Hide skip button when there are no active credentials
			// (prevents loop of no strippen and mismatched identity when strippen refreshing)
			return Current.walletManager.listGreenCards()
				.filter { $0.hasActiveCredentialNowOrInFuture(forDate: date) }
				.isNotEmpty
		}()
	}
	
	private func populateIdentityObjects() {
		
		var items = [IdentityItem]()
		
		let tuples = dataSource.getIdentityInformation(matchingBlobIds: matchingBlobIds)
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
		
		guard selectedBlobIds.isNotEmpty else {
		
			identityItems.value.forEach { $0.state.value = .selectionError }
			errorMessage.value = L.holder_identitySelection_error_makeAChoice()
			return
		}
		
		coordinatorDelegate?.userHasSelectedIdentityGroup(selectedBlobIds: selectedBlobIds)
	}
	
	func userWishesToSkip() {
		
		alert.value = AlertContent(
			title: L.holder_identitySelection_skipAlert_title(),
			subTitle: L.holder_identitySelection_skipAlert_body(),
			okAction: AlertContent.Action(title: L.holder_identitySelection_skipAlert_action(), action: { _ in
				self.coordinatorDelegate?.userHasStoppedTheFlow()
			}, isDestructive: true),
			cancelAction: AlertContent.Action(title: L.general_cancel())
		)
	}
}

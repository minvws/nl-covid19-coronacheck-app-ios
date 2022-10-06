/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit
import Shared

enum IdentitySelectionState {
	case selected
	case unselected
	case selectionError
	case warning(String)
}

class IdentityObject {
	 
	init(blobIds: [String], name: String, content: String, onShowDetails: @escaping () -> Void, onSelectIdentity: @escaping () -> Void, state: Observable<IdentitySelectionState>) {
		self.blobIds = blobIds
		self.name = name
		self.content = content
		self.onShowDetails = onShowDetails
		self.onSelectIdentity = onSelectIdentity
		self.state = state
	}
	
	var blobIds: [String]
	var name: String
	var content: String
	var onShowDetails: () -> Void
	var onSelectIdentity: () -> Void
	var state: Observable<IdentitySelectionState>
}

class IdentitySelectionViewModel {
	
	// Observable variables
	let title = Observable<String>(value: L.holder_identitySelection_title())
	let message = Observable<String>(value: L.holder_identitySelection_message())
	let whyTitle = Observable<String>(value: L.holder_identitySelection_why())
	let actionTitle = Observable<String>(value: L.holder_identitySelection_actionTitle())
	var errorMessage = Observable<String?>(value: nil)
	var objects = Observable<[IdentityObject]>(value: [])
	var alert: Observable<AlertContent?> = Observable(value: nil)
	
	private var selectedBlobIds = [String]()
	
	weak private var coordinatorDelegate: FuzzyMatchingCoordinatorDelegate?
	
	init(coordinatorDelegate: FuzzyMatchingCoordinatorDelegate, blobIds: [[String]]) {
		
		self.coordinatorDelegate = coordinatorDelegate
		self.populateIdentityObjects(blobIds: blobIds)
	}
	
	private func populateIdentityObjects( blobIds: [[String]]) {
		
		//		let eventGroups = Current.walletManager.listEventGroups()
		//		eventGroups.forEach {
		//			logInfo("EG: \($0.uniqueIdentifier)")
		//		}
		
		var identities = [IdentityObject]()
		
		for index in 1...4 {
		
			let identity = IdentityObject(blobIds: ["\(index)"], name: "Rolus \(index)", content: "Vaccinatie content", onShowDetails: {
				logInfo("show details")
			}, onSelectIdentity: {
				self.onSelectIdentity(["\(index)"])
			}, state: Observable<IdentitySelectionState>(value: .unselected))
			
			identities.append(identity)
		}
		
		objects.value = identities
	}
	
	private func onSelectIdentity(_ blobIds: [String]) {
		
		logInfo("onSelectIdentity: \(blobIds)")
		self.selectedBlobIds = blobIds
		objects.value.forEach {
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
		
			objects.value.forEach { $0.state.value = .selectionError }
			errorMessage.value = L.holder_identitySelection_error_makeAChoice()
			return
		}
		
		coordinatorDelegate?.userHasFinishedTheFlow()
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

/*
 holder_identitySelection_error_willBeRemoved

 general_vaccination [existing entry in lokalize]
 general_vaccinations
 general_testresult [existing entry in lokalize]
 general_testresults
 
 */

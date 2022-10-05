/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Shared

enum IdentitySelectionState {
	case selected
	case unselected
	case selectionError
	case warning(String)
}

struct IdentityObject {
	
	var blobIds: [String]
	var name: String
	var content: String
	var showDetails: () -> Void
	var onSelect: () -> Void
	var state: IdentitySelectionState
}

class IdentitySelectionViewModel {
	
	let title = Observable<String>(value: L.holder_identitySelection_title())
	let message = Observable<String>(value: L.holder_identitySelection_message())
	let whyTitle = Observable<String>(value: L.holder_identitySelection_why())
	let actionTitle = Observable<String>(value: L.holder_identitySelection_actionTitle())
	var objects = Observable<[IdentityObject]>(value: [])
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
		
		objects.value = [
			IdentityObject(
				blobIds: ["1"],
				name: "Rolus",
				content: "2 vaccinaties",
				showDetails: {
					logInfo("Pressed details")
				}, onSelect: {
					self.selectedBlobIds = ["1"]
				}, state: .selected
			),
			IdentityObject(
				blobIds: ["2"],
				name: "Rolus 2",
				content: "2 testuitslagen",
				showDetails: {
					logInfo("Pressed details")
				}, onSelect: {
					self.selectedBlobIds = ["2"]
				}, state: .unselected
			),
			IdentityObject(
				blobIds: ["3"],
				name: "Rolus 3",
				content: "2 vaccinaties",
				showDetails: {
					logInfo("Pressed details")
				}, onSelect: {
					self.selectedBlobIds = ["3"]
				}, state: .selectionError
			),
			IdentityObject(
				blobIds: ["4"],
				name: "Rolus 4",
				content: "1 vaccinatie",
				showDetails: {
					logInfo("Pressed details")
				}, onSelect: {
					self.selectedBlobIds = ["4"]
				}, state: .warning(L.holder_identitySelection_error_willBeRemoved())
			)
		]
	}
	
	func userWishedToReadMore() {
		
		coordinatorDelegate?.userWishesMoreInfoAboutWhy()
	}
	
	func userWishesToSaveEvents() {
		
		logInfo("userWishesToSaveEvents")
		coordinatorDelegate?.userHasFinishedTheFlow()
	}
}

/*

 holder_identitySelection_error_makeAChoice
 holder_identitySelection_error_willBeRemoved

 general_vaccination [existing entry in lokalize]
 general_vaccinations
 general_testresult [existing entry in lokalize]
 general_testresults
 
 holder_identitySelection_skipAlert_title
 holder_identitySelection_skipAlert_body
 general_cancel
 holder_identitySelection_skipAlert_action
 
 */

class IdentitySelectionViewController: GenericViewController<IdentitySelectionView, IdentitySelectionViewModel> {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.header = $0 }
		viewModel.actionTitle.observe { [weak self] in self?.sceneView.footerButtonView.primaryTitle = $0 }
		viewModel.whyTitle.observe { [weak self] in self?.sceneView.moreButtonTitle = $0 }
		
		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.userWishesToSaveEvents()
		}
		
		sceneView.readMoreCommand = { [weak self] in
			self?.viewModel.userWishedToReadMore()
		}
		
		viewModel.objects.observe { [weak self] elements in
			guard let self = self else { return }
			elements.map { rowModel -> IdentitySelectionControlView in
				IdentitySelectionControlView.makeView(
						title: rowModel.name,
						content: rowModel.content,
						action: rowModel.showDetails,
						state: rowModel.state
					)
				}
				.forEach(self.sceneView.addIdentitySelectionControlView)
		}
	}
}

extension IdentitySelectionControlView {

	/// Create a event item view
	/// - Parameters:
	///   - title: the title of the view
	///   - content: the sub title of the view
	///   - action: the command to execute when tapped
	/// - Returns: an event item view
	fileprivate static func makeView(
		title: String,
		content: String,
		action: (() -> Void)?,
		state: IdentitySelectionState) -> IdentitySelectionControlView {

		let view = IdentitySelectionControlView()
		view.isUserInteractionEnabled = true
		view.title = title
		view.content = content
		view.actionButtonTitle = L.general_details()
		view.actionButtonCommand = action
		view.state = state
		return view
	}
}

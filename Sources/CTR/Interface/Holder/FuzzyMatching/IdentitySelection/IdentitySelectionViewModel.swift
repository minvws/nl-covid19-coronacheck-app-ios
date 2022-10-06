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
	
	let title = Observable<String>(value: L.holder_identitySelection_title())
	let message = Observable<String>(value: L.holder_identitySelection_message())
	let whyTitle = Observable<String>(value: L.holder_identitySelection_why())
	let actionTitle = Observable<String>(value: L.holder_identitySelection_actionTitle())
	var errorMessage = Observable<String?>(value: nil)
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
		
		coordinatorDelegate?.userHasFinishedTheFlow()
	}
}

/*
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

class IdentitySelectionViewController: TraitWrappedGenericViewController<IdentitySelectionView, IdentitySelectionViewModel> {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		setupBinding()
		setupSkipButton()
		addBackButton()
	}
	
	private func setupBinding() {
		
		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.header = $0 }
		viewModel.actionTitle.observe { [weak self] in self?.sceneView.footerButtonView.primaryTitle = $0 }
		viewModel.whyTitle.observe { [weak self] in self?.sceneView.moreButtonTitle = $0 }
		viewModel.errorMessage.observe { [weak self] in self?.sceneView.errorMessage = $0 }
		
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
						selectAction: rowModel.onSelectIdentity,
						detailsAction: rowModel.onShowDetails,
						state: rowModel.state
					)
				}
				.forEach(self.sceneView.addIdentitySelectionControlView)
		}
	}
	
	private func setupSkipButton() {
		
		let config = UIBarButtonItem.Configuration(
			target: self,
			action: #selector(onSkip),
			content: .text(L.general_skip()),
			tintColor: C.primaryBlue(),
			accessibilityIdentifier: "SkipButton",
			accessibilityLabel: L.general_skip()
		)
		navigationItem.rightBarButtonItem = .create(config)
	}
	
	@objc func onSkip() {
		
		viewModel.userWishesToSkip()
	}
}

extension IdentitySelectionControlView {
	
	/// Create a IdentitySelectionControl view
	/// - Parameters:
	///   - title: the title of the view
	///   - content: the content of the view
	///   - selectAction: the action when the view is selected
	///   - detailsAction: the action when the details button is pressed
	///   - state: the state of the button
	/// - Returns: IdentitySelectionControlView
	fileprivate static func makeView(
		title: String,
		content: String,
		selectAction: (() -> Void)?,
		detailsAction: (() -> Void)?,
		state: Observable<IdentitySelectionState>) -> IdentitySelectionControlView {
		
		let view = IdentitySelectionControlView()
		view.isUserInteractionEnabled = true
		view.title = title
		view.content = content
		view.actionButtonTitle = L.general_details()
		view.actionButtonCommand = detailsAction
		view.selectionButtonCommand = selectAction
		
		state.observe { view.state = $0 }
		return view
	}
}

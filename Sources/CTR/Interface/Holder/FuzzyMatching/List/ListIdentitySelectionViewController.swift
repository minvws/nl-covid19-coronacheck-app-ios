/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Shared
import ReusableViews
import UIKit

class ListIdentitySelectionViewController: TraitWrappedGenericViewController<ListIdentitySelectionView, ListIdentitySelectionViewModel> {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		setupBinding()
		setupCallbacks()
		addBackButton()
	}
	
	private func setupBinding() {
		
		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.header = $0 }
		viewModel.actionTitle.observe { [weak self] in self?.sceneView.footerButtonView.primaryTitle = $0 }
		viewModel.whyTitle.observe { [weak self] in self?.sceneView.moreButtonTitle = $0 }
		viewModel.errorMessage.observe {[weak self] errorMessage in
			self?.sceneView.errorMessage = errorMessage
			if let errorMessage {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					UIAccessibility.post(notification: .announcement, argument: errorMessage)
				}
			}
		}
	
		viewModel.identityItems.observe { [weak self] elements in
			guard let self else { return }
			elements.map { rowModel -> IdentityControlView in
				IdentityControlView.makeView(
						title: rowModel.name,
						content: rowModel.eventCountInformation,
						selectAction: rowModel.onSelectIdentity,
						detailsAction: rowModel.onShowDetails,
						state: rowModel.state
					)
				}
				.forEach(self.sceneView.addIdentityControlView)
		}
		
		viewModel.alert.observe { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}
		
		viewModel.showSkipButton.observe { [weak self] in
			guard let self else { return }
			if $0 {
				self.setupSkipButton()
			} else {
				self.navigationItem.rightBarButtonItem = nil
			}
		}
	}
	
	private func setupCallbacks() {
		
		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.userWishesToSaveEvents()
		}
		
		sceneView.readMoreCommand = { [weak self] in
			self?.viewModel.userWishedToReadMore()
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

extension IdentityControlView {
	
	/// Create a IdentitySelectionControl view
	/// - Parameters:
	///   - title: the title of the view
	///   - content: the content of the view
	///   - selectAction: the action when the view is selected
	///   - detailsAction: the action when the details button is pressed
	///   - state: the state of the button
	/// - Returns: IdentityControlView
	fileprivate static func makeView(
		title: String,
		content: String,
		selectAction: (() -> Void)?,
		detailsAction: (() -> Void)?,
		state: Observable<IdentityControlViewState>) -> IdentityControlView {
		
		let view = IdentityControlView()
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

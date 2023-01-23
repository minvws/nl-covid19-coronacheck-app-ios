/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

class RemoteEventStartViewController: TraitWrappedGenericViewController<RemoteEventStartView, RemoteEventStartViewModel> {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		setupBinding()
		setupInteraction()
	}
	
	private func setupBinding() {
		
		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$primaryButtonIcon.binding = { [weak self] in self?.sceneView.primaryButtonIcon = $0 }
		viewModel.$checkboxTitle.binding = { [weak self] in self?.sceneView.checkboxTitle = $0 }
		viewModel.$combineVaccinationAndPositiveTest.binding = { [weak self] in self?.sceneView.info = $0 }
	}
	
	private func setupInteraction() {
		
		sceneView.primaryTitle = L.holderVaccinationStartAction()
		sceneView.primaryButtonTappedCommand = { [weak self] in self?.viewModel.primaryButtonTapped() }
		
		sceneView.secondaryButtonTitle = L.holderVaccinationStartNodigid()
		sceneView.secondaryButtonTappedCommand = { [weak self] in self?.viewModel.secondaryButtonTapped() }
		
		sceneView.contentTextView.linkTouchedHandler = { [weak self] url in self?.viewModel.openUrl(url) }
		
		sceneView.didToggleCheckboxCommand = { [weak self] value in self?.viewModel.checkboxToggled(value: value) }
		
		addBackButton()
	}
}

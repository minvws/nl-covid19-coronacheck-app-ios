/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ShowQRItemViewController: TraitWrappedGenericViewController<ShowQRItemView, ShowQRItemViewModel> {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		setupBinding()
		setupListeners()
		
		viewModel.$overlayTitle.binding = { [weak self] in self?.sceneView.overlayView.title = $0 }
		viewModel.$overlayRevealTitle.binding = { [weak self] in self?.sceneView.overlayView.action = $0 }
		viewModel.$overlayInfoTitle.binding = { [weak self] in self?.sceneView.overlayView.info = $0 }
		viewModel.$overlayIcon.binding = { [weak self] in self?.sceneView.overlayView.icon = $0 }
		
		sceneView.overlayView.revealButtonCommand = { [weak self] in self?.viewModel.revealHiddenQR() }
		sceneView.overlayView.infoButtonCommand = { [weak self] in self?.viewModel.infoButtonTapped() }
	}
	
	private func setupBinding() {
		
		viewModel.$qrAccessibility.binding = { [weak self] in
			
			self?.sceneView.accessibilityDescription = $0
		}
		
		viewModel.$visibilityState.binding = { [weak self] in
			self?.sceneView.visibilityState = $0
		}
	}
	
	private func setupListeners() {
		
		// set observer for UIApplication.willEnterForegroundNotification
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(checkValidity),
			name: UIApplication.willEnterForegroundNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(checkValidity),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)
	}
	
	/// Check the validity of the scene
	@objc func checkValidity() {
		
		// Check the Validity of the QR
		viewModel.checkQRValidity()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		viewModel.updateQRVisibility()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		checkValidity()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		viewModel.stopValidityTimer()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		
		super.viewDidDisappear(animated)
		viewModel.resetHiddenState()
	}
}

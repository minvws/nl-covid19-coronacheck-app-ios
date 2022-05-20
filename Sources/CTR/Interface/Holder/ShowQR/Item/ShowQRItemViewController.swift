/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ShowQRItemViewController: BaseViewController, Logging {

	private let viewModel: ShowQRItemViewModel

	let sceneView = ShowQRItemView()

	var previousOrientation: UIInterfaceOrientation?

	// MARK: Initializers

	init(viewModel: ShowQRItemViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle

	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()
		
		setupBinding()
		setupListeners()

		sceneView.irrelevantView.title = L.holderShowqrQrhidden()
		sceneView.irrelevantView.action = L.holderShowqrShowqr()
		sceneView.irrelevantView.actionButtonCommand = { [weak self] in self?.viewModel.revealIrrelevantQR() }
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
		viewModel.resetIrrelevancy()
	}
}

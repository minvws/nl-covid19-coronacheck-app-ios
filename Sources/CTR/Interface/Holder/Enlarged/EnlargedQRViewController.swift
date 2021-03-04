/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class EnlargedQRViewController: BaseViewController {

	private let viewModel: EnlargedQRViewModel

	let sceneView = EnlargedQRImageView()

	var screenCaptureInProgress = false

	// MARK: Initializers

	init(viewModel: EnlargedQRViewModel) {

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

		sceneView.backgroundColor = .white

		edgesForExtendedLayout = []

		viewModel.$qrTitle.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$qrSubTitle.binding = { [weak self] in self?.sceneView.message = $0 }

		viewModel.$qrMessage.binding = { [weak self] in

			if let value = $0 {
				let image = value.generateQRCode()
				self?.sceneView.qrImage = image
			} else {
				self?.sceneView.qrImage = nil
			}
		}

		viewModel.$showValidQR.binding = { [weak self] in

			if $0 {
				self?.sceneView.largeQRimageView.isHidden = false
			} else {
				self?.sceneView.largeQRimageView.isHidden = true
			}
		}

		viewModel.$hideQRForCapture.binding = { [weak self] in

			self?.screenCaptureInProgress = $0
			self?.sceneView.hideQRImage = $0
		}

		setupListeners()

		addCloseButton(action: #selector(closeButtonTapped), accessibilityLabel: .close)
	}

	/// User tapped on the button
	@objc private func closeButtonTapped() {

		viewModel.dismiss()
	}

	func setupListeners() {

		// set observer for UIApplication.willEnterForegroundNotification
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(checkValidity),
			name: UIApplication.willEnterForegroundNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self, selector:
				#selector(checkValidity),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)
	}

	/// Check the validity of the scene
	@objc func checkValidity() {

		// Check the Validity of the QR
		viewModel.checkQRValidity()

		// Check if we are being recorded
		viewModel.preventScreenCapture()

		// Check the brightness
		if !sceneView.largeQRimageView.isHidden {
			viewModel.setBrightness()
		}

		sceneView.resume()
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		checkValidity()
		sceneView.play()
	}

	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)
		viewModel.setBrightness(reset: true)
		viewModel.validityTimer?.invalidate()
		viewModel.validityTimer = nil
	}

//	deinit {
//		NotificationCenter.default.removeObserver(self)
//	}
}

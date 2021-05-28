/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ShowQRViewController: BaseViewController {

	private let viewModel: ShowQRViewModel

	let sceneView = ShowQRImageView()

	var screenCaptureInProgress = false

	var previousOrientation: UIInterfaceOrientation?

	// MARK: Initializers

	init(viewModel: ShowQRViewModel) {

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
		
		setupBinding()
		setupListeners()
	}

	func setupBinding() {

		viewModel.$title.binding = { [weak self] in
			self?.title = $0
			self?.sceneView.accessibilityDescription = $0
		}

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

		viewModel.$hideForCapture.binding = { [weak self] in

			self?.screenCaptureInProgress = $0
			self?.sceneView.hideQRImage = $0
		}

		viewModel.$showScreenshotWarning.binding = { [weak self] in

			if $0 {
				self?.showError(
					.holderEnlargedScreenshotTitle,
					message: .holderEnlargedScreenshotMessage
				)
			}
		}
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

		previousOrientation = OrientationUtility.currentOrientation()
		OrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
	}

	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)
		viewModel.setBrightness(reset: true)
//		viewModel.validityTimer?.invalidate()
//		viewModel.validityTimer = nil
		OrientationUtility.lockOrientation(.all, andRotateTo: previousOrientation ?? .portrait)
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import AVFoundation
import UIKit

class ScanViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate, Logging {

	var loggingCategory: String = "ScanViewController"

	var captureSession: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!

	let sceneView = ScanView()

	var previousOrientation: UIInterfaceOrientation?
    
    var torchButton: UIBarButtonItem?
    var torchEnableLabel: String?
    var torchDisableLabel: String?

	// Actions to perform on the navigationController at the moment that we are removing this screen.
	// 	Background:
	// 		we use `dashboardNavigationController?.setViewControllers([dashboardViewController], animated: false)`
	// 		when dismissing this screen, which removes the reference to `self.navigationController` even before
	// 		`self.viewWillDisappear` is called. So we need to maintain a (weak) reference to the navigationController
	// 		inside this closure, so that we can perform some teardown steps on it as we're dismissed.
	private var navigationControllerTeardown: (() -> Void)?

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationControllerTeardown = { [weak navigationController] in
			// Reset navigation title color
			let textAttributes = [
				NSAttributedString.Key.foregroundColor: Theme.colors.dark,
				NSAttributedString.Key.font: Theme.fonts.bodyMontserrat
			]
			navigationController?.navigationBar.titleTextAttributes = textAttributes
			navigationController?.navigationBar.tintColor = Theme.colors.dark
		}
	}

	func setupScan() {

		guard !Platform.isSimulator else {
			return
		}

		sceneView.cameraView.backgroundColor = UIColor.black
		captureSession = AVCaptureSession()

		guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
		let videoInput: AVCaptureDeviceInput

		do {
			videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
		} catch {
			return
		}

		if captureSession.canAddInput(videoInput) {
			captureSession.addInput(videoInput)
		} else {
			failed()
			return
		}

		let metadataOutput = AVCaptureMetadataOutput()

		if captureSession.canAddOutput(metadataOutput) {
			captureSession.addOutput(metadataOutput)

			metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			if Configuration().getEnvironment() == "test" {
				metadataOutput.metadataObjectTypes = [.qr, .aztec]
			} else {
				metadataOutput.metadataObjectTypes = [.qr]
			}
		} else {
			failed()
			return
		}

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = sceneView.cameraView.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		sceneView.cameraView.layer.addSublayer(previewLayer)

		captureSession.startRunning()
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		// Force navigation title color to white
		let textAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.white,
			NSAttributedString.Key.font: Theme.fonts.bodyMontserratFixed
		]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.tintColor = .white

		previousOrientation = OrientationUtility.currentOrientation()
		OrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		setupScan()

		if !Platform.isSimulator, captureSession?.isRunning == false {
			captureSession.startRunning()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if !Platform.isSimulator, captureSession?.isRunning == true {
			captureSession.stopRunning()
		}

		navigationControllerTeardown?()

		OrientationUtility.lockOrientation(.all, andRotateTo: previousOrientation ?? .portrait)
	}

	func failed() {
		let ac = UIAlertController(
			title: "Scanning not supported",
			message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
			preferredStyle: .alert
		)
		ac.addAction(UIAlertAction(title: L.generalOk(), style: .default))
		present(ac, animated: true)
		captureSession = nil
	}

	func metadataOutput(
		_ output: AVCaptureMetadataOutput,
		didOutput metadataObjects: [AVMetadataObject],
		from connection: AVCaptureConnection) {

		captureSession.stopRunning()

		if let metadataObject = metadataObjects.first {
			guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
			guard let stringValue = readableObject.stringValue else { return }
			AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			found(code: stringValue)
		}
	}

	func found(code: String) {

		logInfo("CTR: Found code: \(code)")
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}

	/// Toggle the torch
	@objc func toggleTorch() {

		guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
			// No camera or no torch
			return
		}
		do {
			try device.lockForConfiguration()
            if device.torchMode == .on {
				device.torchMode = .off
                torchChanged(enabled: false)
			} else {
				try device.setTorchModeOn(level: 1.0)
                torchChanged(enabled: true)
			}
			device.unlockForConfiguration()
		} catch {
			self.logError("toggleTorch: \(error)")
		}
	}
    
    func torchChanged(enabled: Bool) {
        let label = enabled ? torchDisableLabel : torchEnableLabel
        torchButton?.accessibilityLabel = label
        torchButton?.title = label
    }

	/// Add a torch button to the navigation bar.
	/// - Parameters:
	///   - action: The action when the users taps the torch button
	///   - enableLabel: The label when enabled
	///   - disableLabel: The label when disabled
	func addTorchButton(
		action: Selector,
		enableLabel: String,
		disableLabel: String) {
		
		let config = UIBarButtonItem.Configuration(target: self,
												   action: action,
												   image: I.torch(),
												   accessibilityIdentifier: "TorchButton",
												   accessibilityLabel: enableLabel)
		let button: UIBarButtonItem = .create(config)
		navigationItem.rightBarButtonItem = button
		
		self.torchButton = button
		self.torchEnableLabel = enableLabel
		self.torchDisableLabel = disableLabel
	}
	
	/// Resume scanning after being stopped
	func resumeScanning() {
		captureSession.startRunning()
	}
}

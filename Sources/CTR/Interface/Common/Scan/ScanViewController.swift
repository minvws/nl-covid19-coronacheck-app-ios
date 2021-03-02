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

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
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
			metadataOutput.metadataObjectTypes = [.qr]
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
			NSAttributedString.Key.font: Theme.fonts.bodyMontserrat
		]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.tintColor = .white
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

		// Reset navigation title color
		let textAttributes = [
			NSAttributedString.Key.foregroundColor: Theme.colors.dark,
			NSAttributedString.Key.font: Theme.fonts.bodyMontserrat
		]
		navigationController?.navigationBar.titleTextAttributes = textAttributes
		navigationController?.navigationBar.tintColor = Theme.colors.dark
	}

	func failed() {
		let ac = UIAlertController(
			title: "Scanning not supported",
			message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
			preferredStyle: .alert
		)
		ac.addAction(UIAlertAction(title: .ok, style: .default))
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

		print("CTR: Found code: \(code)")
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}

	/// Toggle the torch
	@objc func toggleTorch() {

		guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch else {
			// No camera or no torch
			return
		}
		do {
			try device.lockForConfiguration()
			if device.torchMode == AVCaptureDevice.TorchMode.on {
				device.torchMode = AVCaptureDevice.TorchMode.off
			} else {
				try device.setTorchModeOn(level: 1.0)
			}
			device.unlockForConfiguration()
		} catch {
			self.logError("toggleTorch: \(error)")
		}
	}

	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: the action when the users taps the close button
	///   - accessibilityLabel: the label for Voice Over
	func addTorchButton(
		action: Selector?,
		accessibilityLabel: String) {

		let button = UIBarButtonItem(
			image: .torch,
			style: .plain,
			target: self,
			action: action
		)
		button.accessibilityIdentifier = "TorchButton"
		button.accessibilityLabel = accessibilityLabel
		button.accessibilityTraits = UIAccessibilityTraits.button
		navigationItem.rightBarButtonItem = button
		navigationController?.navigationItem.rightBarButtonItem = button
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import AVFoundation
import UIKit

class ScanViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {

	var captureSession: AVCaptureSession!
	var previewLayer: AVCaptureVideoPreviewLayer!

	let sceneView = ScanView()

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

    override func viewDidLoad() {
        super.viewDidLoad()

//		sceneView.primaryButtonTappedCommand = { [weak self] in
//
//			self?.captureSession.startRunning()
//		}
    }

	func setupScan() {

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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		setupScan()

		if captureSession?.isRunning == false {
			captureSession.startRunning()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if captureSession?.isRunning == true {
			captureSession.stopRunning()
		}
	}

	func failed() {
		let ac = UIAlertController(
			title: "Scanning not supported",
			message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
			preferredStyle: .alert
		)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
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
}

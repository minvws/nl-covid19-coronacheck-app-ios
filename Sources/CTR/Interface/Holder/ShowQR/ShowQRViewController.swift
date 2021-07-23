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

	private func setupBinding() {

		viewModel.$title.binding = { [weak self] in
            
			self?.title = $0
		}
        
        viewModel.$qrAccessibility.binding = { [weak self] in
            
            self?.sceneView.accessibilityDescription = $0
        }

		viewModel.$infoButtonAccessibility.binding = { [weak self] in

			self?.addInfoButton(action: #selector(self?.informationButtonTapped), accessibilityLabel: $0 ?? "")
		}

		viewModel.$qrImage.binding = { [weak self] in self?.sceneView.qrImage = $0 }

		viewModel.$showValidQR.binding = { [weak self] in

			let hideForCapture = self?.sceneView.hideQRImage ?? false

			if $0 && !hideForCapture {
				self?.sceneView.largeQRimageView.isHidden = false
			} else {
				self?.sceneView.largeQRimageView.isHidden = true
			}
		}

		viewModel.$hideForCapture.binding = { [weak self] in

			self?.sceneView.hideQRImage = $0
		}

		viewModel.$screenshotWasTaken.binding = { [weak self] in

			if $0 {
				self?.showError(
					L.holderEnlargedScreenshotTitle(),
					message: L.holderEnlargedScreenshotMessage()
				)
			}
		}

		viewModel.$showInternationalAnimation.binding = { [weak self] in
			if $0 {
				self?.sceneView.setupForInternational()
			}
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
		sceneView.play()
		previousOrientation = OrientationUtility.currentOrientation()
		OrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
	}

	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)
		checkValidity()
	}

	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)
		viewModel.setBrightness(reset: true)
		viewModel.stopValidityTimer()
		OrientationUtility.lockOrientation(.all, andRotateTo: previousOrientation ?? .portrait)
	}

	/// Add an information button to the navigation bar.
	/// - Parameters:
	///   - action: the action when the users taps the information button
	///   - accessibilityLabel: the label for Voice Over
	func addInfoButton(
		action: Selector?,
		accessibilityLabel: String) {

		let button = UIBarButtonItem(
			image: .questionMark,
			style: .plain,
			target: self,
			action: action
		)
        button.title = accessibilityLabel
		button.accessibilityIdentifier = "InformationButton"
		button.accessibilityTraits = .button
		navigationItem.rightBarButtonItem = button
		navigationController?.navigationItem.rightBarButtonItem = button
	}

	@objc func informationButtonTapped() {

		viewModel.showMoreInformation()
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class HolderDashboardViewController: BaseViewController {

	private let viewModel: HolderDashboardViewModel

	let sceneView = HolderDashboardView()

	// MARK: Initializers

	init(viewModel: HolderDashboardViewModel) {

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

		viewModel.$title.binding = { self.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }
		viewModel.$qrTitle.binding = { self.sceneView.qrView.title = $0 }
		viewModel.$qrSubTitle.binding = { self.sceneView.qrView.message = $0 }
		viewModel.$expiredTitle.binding = { self.sceneView.expiredQRView.title = $0 }
		viewModel.$appointmentCard.binding = { self.styleCard(self.sceneView.appointmentCard, cardInfo: $0) }
		viewModel.$createCard.binding = { self.styleCard(self.sceneView.createCard, cardInfo: $0) }

		viewModel.$qrMessage.binding = {

			if let value = $0 {
				let image = self.generateQRCode(from: value)
				self.sceneView.qrView.qrImage = image
				self.sceneView.largeQRimageView.image = image
			} else {
				self.sceneView.qrView.qrImage = nil
				self.sceneView.largeQRimageView.image = nil
			}
		}

		viewModel.$showValidQR.binding = {
			if $0 {
				self.sceneView.qrView.isHidden = false
				// Scroll to top
				self.sceneView.scrollView.setContentOffset(.zero, animated: true)
//				self.setupLink()
			} else {
				self.sceneView.qrView.isHidden = true
			}
		}

		viewModel.$showExpiredQR.binding = {
			if $0 {
				self.sceneView.expiredQRView.isHidden = false
			} else {
				self.sceneView.expiredQRView.isHidden = true
			}
		}

		viewModel.$hideQRForCapture.binding = {

			self.sceneView.hideQRImage = $0
			self.largeQRTapped()
		}

		setupListeners()

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	/// Setup a gesture recognizer for underlined text
	private func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showLargeQR))
		sceneView.qrView.addGestureRecognizer(tapGesture)
		sceneView.qrView.isUserInteractionEnabled = true
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

	@objc func checkValidity() {

		viewModel.checkQRValidity()
		if !sceneView.qrView.isHidden {
			viewModel.setBrightness()
		}
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		checkValidity()
	}

	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)
		viewModel.setBrightness(reset: true)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: Helper methods

	/// Style a dashboard card view
	/// - Parameters:
	///   - card: the card view
	///   - cardInfo: the card information
	func styleCard(_ card: CardView, cardInfo: CardInfo) {

		card.title = cardInfo.title
		card.message = cardInfo.message
		card.primaryTitle = cardInfo.actionTitle
		card.backgroundImage = cardInfo.image
		card.backgroundImageView.layer.contentsRect = cardInfo.imageRect
		card.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.cardTapped(cardInfo.identifier)
		}
	}

	/// Generate a QR image
	/// - Parameter data: the data to embed
	/// - Returns: QR image
	func generateQRCode(from data: Data) -> UIImage? {

		if let filter = CIFilter(name: "CIQRCodeGenerator") {
			filter.setValue(data, forKey: "inputMessage")
			let transform = CGAffineTransform(scaleX: 3, y: 3)

			if let output = filter.outputImage?.transformed(by: transform) {
				return UIImage(ciImage: output)
			}
		}
		return nil
	}

	// MARK: User interaction

	/// User tapped on the link
	@objc func showLargeQR() {

		self.navigationController?.isNavigationBarHidden = true
		sceneView.largeOverlay.isHidden = false
		sceneView.largeQRimageView.isHidden = false
		viewModel.setBrightness()

		qrTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(largeQRTapped))
		if let gesture = qrTapGestureRecognizer {
			sceneView.addGestureRecognizer(gesture)
			sceneView.isUserInteractionEnabled = true
		}
	}

	/// The tap gesture recognizer on the qr image
	var qrTapGestureRecognizer: UITapGestureRecognizer?

	/// User tapped on the link
	@objc func largeQRTapped() {

		self.navigationController?.isNavigationBarHidden = false
		sceneView.largeOverlay.isHidden = true
		sceneView.largeQRimageView.isHidden = true
		viewModel.setBrightness(reset: true)
		if let gesture = qrTapGestureRecognizer {
			sceneView.removeGestureRecognizer(gesture)
		}
	}
}

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
	
	var screenCaptureInProgress = false
	
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
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		viewModel.start()
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		viewModel.$qrTitle.binding = { [weak self] in self?.sceneView.qrView.title = $0 }
		viewModel.$qrSubTitle.binding = { [weak self] in self?.sceneView.qrView.subTitle = $0 }
		viewModel.$qrValidUntilTitle.binding = { [weak self] in self?.sceneView.qrView.message = $0 }
		viewModel.$expiredTitle.binding = { [weak self] in self?.sceneView.expiredQRView.title = $0 }
		viewModel.$appointmentCard.binding = { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.styleCard(strongSelf.sceneView.appointmentCard, cardInfo: $0) }
		viewModel.$createCard.binding = { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.styleCard(strongSelf.sceneView.createCard, cardInfo: $0) }
		
		viewModel.$qrMessage.binding = {
			
			if let value = $0 {
				let image = value.generateQRCode()
				self.sceneView.qrView.qrImage = image
			} else {
				self.sceneView.qrView.qrImage = nil
			}
		}
		
		viewModel.$showValidQR.binding = {
			
			if $0 {
				self.sceneView.qrView.isHidden = false
				self.setupLink()
			} else {
				self.sceneView.qrView.isHidden = true
			}
		}
		
		viewModel.$showExpiredQR.binding = {
			
			if $0 {
				self.sceneView.expiredQRView.isHidden = false
				self.sceneView.expiredQRView.closeButtonTappedCommand = { [weak self] in
					self?.viewModel.closeExpiredRQ()
				}
			} else {
				self.sceneView.expiredQRView.isHidden = true
			}
		}
		
		viewModel.$hideQRForCapture.binding = {
			
			self.screenCaptureInProgress = $0
			self.sceneView.hideQRImage = $0
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

		// Resume the animation
		sceneView.resume()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		checkValidity()
		sceneView.play()

		// Scroll to top
		sceneView.scrollView.setContentOffset(.zero, animated: false)
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
	
	// MARK: User interaction
	
	/// User tapped on the link
	@objc func showLargeQR() {
		
		guard !screenCaptureInProgress else {
			return
		}
		
		viewModel.navigateToEnlargedQR()
	}
}

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
		viewModel.$appointmentCard.binding = { self.styleCard(self.sceneView.appointmentCard, cardInfo: $0) }
		viewModel.$createCard.binding = { self.styleCard(self.sceneView.createCard, cardInfo: $0) }

		viewModel.$qrMessage.binding = {

			if let value = $0 {
				let image = self.generateQRCode(from: value)
				self.sceneView.qrView.qrImage = image
				self.sceneView.qrView.isHidden = false
				// Scroll to top
				self.sceneView.scrollView.setContentOffset(.zero, animated: true)
			} else {
				self.sceneView.qrView.isHidden = true
			}
		}
		
		// Only show an arrow as back button
		styleBackButton(buttonText: "")
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		viewModel.checkQRMessage()
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
		card.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.cardClicked(cardInfo.identifier)
		}
	}

	/// Generate a QR image from a string
	/// - Parameter string: the string to embed
	/// - Returns: QR image
	func generateQRCode(from string: String) -> UIImage? {

		let data = string.data(using: String.Encoding.ascii)

		if let filter = CIFilter(name: "CIQRCodeGenerator") {
			filter.setValue(data, forKey: "inputMessage")
			let transform = CGAffineTransform(scaleX: 3, y: 3)

			if let output = filter.outputImage?.transformed(by: transform) {
				return UIImage(ciImage: output)
			}
		}
		return nil
	}
}

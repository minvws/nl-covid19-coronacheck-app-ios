/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class HolderDashboardView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let messageLineHeight: CGFloat = 26
		static let cardRatio: CGFloat = UIDevice.current.isSmallScreen ? 1.2 : 1.5

		// Margin
		static let margin: CGFloat = 10
	}

	// MARK: Singleton Cards

	/// "To get access to the pilot, you need a.. "
	let headerMessageLabel: Label = {

		return Label(body: nil).multiline()
	}()

//	/// The QR Card
//	let qrCardView: QRCardView = {
//
//		let view = QRCardView()
//		view.translatesAutoresizingMaskIntoConstraints = false
//		view.isHidden = true
//		return view
//	}()

	/// The create QR Card
	let makeQRCard: CardView = {

		let view = CardView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let changeRegionView: ChangeRegionView = {
		let view = ChangeRegionView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
	}

	// MARK: Public Access

//	/// The  message
//	var message: String? {
//		didSet {
//			messageLabel.text = message
//		}
//	}
//
//	/// Hide the QR Image
//	var hideQRImage: Bool = false {
//		didSet {
//			if qrCardView.time != nil {
//				qrCardView.isHidden = hideQRImage
//			}
//		}
//	}
}

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

	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The image view for the QR image
	let largeQRimageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		view.backgroundColor = .gray
		return view
	}()

	let largeOverlay: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		view.isHidden = true
		return view
	}()

	/// The QR Card
	let qrView: QRImageView = {

		let view = QRImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	let expiredQRView: ExpiredQRView = {

		let view = ExpiredQRView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	/// The appointment Card
	let appointmentCard: CardView = {

		let view = CardView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.appointment
		return view
	}()

	/// The create QR Card
	let createCard: CardView = {

		let view = CardView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.create
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(qrView)
		stackView.addArrangedSubview(expiredQRView)
		stackView.addArrangedSubview(appointmentCard)
		stackView.addArrangedSubview(createCard)

		largeOverlay.embed(in: self)
		addSubview(largeQRimageView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// CardViews
			appointmentCard.widthAnchor.constraint(
				equalTo: appointmentCard.heightAnchor,
				multiplier: ViewTraits.cardRatio
			),
			createCard.widthAnchor.constraint(
				equalTo: createCard.heightAnchor,
				multiplier: ViewTraits.cardRatio
			),

			largeQRimageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			largeQRimageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			largeQRimageView.heightAnchor.constraint(equalTo: largeQRimageView.widthAnchor),
			largeQRimageView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			),
			largeQRimageView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	// MARK: Public Access

	/// The  message
	var message: String? {
		didSet {
			messageLabel.text = message
		}
	}

	/// Hide the QR Image
	var hideQRImage: Bool = false {
		didSet {
			qrView.hideQRImage = hideQRImage
		}
	}
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class QRImageView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 8
		static let shadowOpacity: Float = 0.3

		// Margins
		static let margin: CGFloat = 24.0
		static let labelSidemargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 20.0
		static let imageSidemargin: CGFloat = UIDevice.current.isSmallScreen ? 20.0 : 40.0
	}

	let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The title label
	let titleLabel: Label = {

		return Label(title3: nil)
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(subhead: nil)
	}()

	override func setupViews() {

		super.setupViews()

		backgroundColor = .white

		titleLabel.textAlignment = .center
		messageLabel.textAlignment = .center

		layer.cornerRadius = ViewTraits.cornerRadius

		// Shadow
		layer.shadowColor = Theme.colors.shadow.cgColor
		layer.shadowOpacity = ViewTraits.shadowOpacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.shadowRadius
		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(titleLabel)
		addSubview(imageView)
		addSubview(messageLabel)
	}
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.labelSidemargin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.labelSidemargin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: imageView.topAnchor,
				constant: -ViewTraits.margin
			),

			// QR View
			imageView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.imageSidemargin
			),
			imageView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.imageSidemargin
			),
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
			imageView.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.margin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.labelSidemargin
			),
			messageLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.labelSidemargin
			)
		])
	}

	/// The  message
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The  message
	var message: String? {
		didSet {
			messageLabel.text = message
		}
	}
}

class HolderDashboardView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let messageLineHeight: CGFloat = 26
		static let cardRatio: CGFloat = UIDevice.current.isSmallScreen ? 1.2 : 1.5

		// Margins
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 16.0
		static let spacing: CGFloat = 32.0
	}

	/// The scrollview
	let scrollView: UIScrollView = {

		let view = UIScrollView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stackview for the content
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .equalSpacing
		view.spacing = ViewTraits.spacing
		return view
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	let qrView: QRImageView = {

		let view = QRImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	let appointmentCard: CardView = {

		let view = CardView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.appointment
		return view
	}()

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
		stackView.addArrangedSubview(appointmentCard)
		stackView.addArrangedSubview(createCard)

		scrollView.addSubview(stackView)

		addSubview(scrollView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Scrollview
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.margin
			),

			// StackView
			stackView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2.0 * ViewTraits.margin
			),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			stackView.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: ViewTraits.topMargin
			),
			stackView.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			),

			// CardView
			appointmentCard.widthAnchor.constraint(equalTo: appointmentCard.heightAnchor, multiplier: ViewTraits.cardRatio),
			createCard.widthAnchor.constraint(equalTo: createCard.heightAnchor, multiplier: ViewTraits.cardRatio)
		])
	}

	/// The  message
	var message: String? {
		didSet {
			messageLabel.text = message
		}
	}
}

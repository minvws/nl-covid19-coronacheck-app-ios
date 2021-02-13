/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let messageLineHeight: CGFloat = 22
		static let cornerRadius: CGFloat = 15

		// Margins
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 20.0
	}

	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	let cameraView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let overlayView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()

	let sampleMask: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		return view
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		messageLabel.textColor = .white
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		cameraView.embed(in: self)
		overlayView.embed(in: self)
		overlayView.addSubview(sampleMask)
		addSubview(messageLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		NSLayoutConstraint.activate([

			messageLabel.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.topMargin
			),
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	override func layoutSubviews() {

		super.layoutSubviews()

		sampleMask.frame = overlayView.frame

		let maskLayer = CALayer()
		maskLayer.frame = sampleMask.bounds
		let rectWidth = sampleMask.frame.size.width - 2 * ViewTraits.margin
		let rectLayer = CAShapeLayer()
		rectLayer.frame = CGRect(
			x: 0,
			y: 0,
			width: sampleMask.frame.size.width,
			height: sampleMask.frame.size.height
		)
		let finalPath = UIBezierPath(
			roundedRect: CGRect(
				x: 0,
				y: 0,
				width: sampleMask.frame.size.width,
				height: sampleMask.frame.size.height
			),
			cornerRadius: 0
		)
		let rectPath = UIBezierPath(
			roundedRect: CGRect(
				x: ViewTraits.margin,
				y: (sampleMask.frame.size.height - rectWidth) / 2,
				width: rectWidth,
				height: rectWidth
			),
			cornerRadius: ViewTraits.cornerRadius
		)
		finalPath.append(rectPath.reversing())
		rectLayer.path = finalPath.cgPath
		maskLayer.addSublayer(rectLayer)
		sampleMask.layer.mask = maskLayer
	}

	// MARK: Public Access

	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight, alignment: .center)
		}
	}
}

/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class ScanView: BaseView {
	
	/// The display constants
	private struct ViewTraits {

		static let cornerRadius: CGFloat = 15
		static let margin: CGFloat = 20.0
		static let maskOffset: CGFloat = 100.0
	}
	
	let cameraView = UIView()
	
	let sampleMask: UIView = {

		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		return view
	}()
	
	let maskLayoutGuide = UILayoutGuide()
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		cameraView.embed(in: self)
		sampleMask.embed(in: self)
		
		addLayoutGuide(maskLayoutGuide)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		maskLayoutGuide.leftAnchor.constraint(equalTo: sampleMask.leftAnchor, constant: ViewTraits.margin).isActive = true
		maskLayoutGuide.rightAnchor.constraint(equalTo: sampleMask.rightAnchor, constant: -ViewTraits.margin).isActive = true
		maskLayoutGuide.heightAnchor.constraint(equalTo: maskLayoutGuide.widthAnchor).isActive = true
		maskLayoutGuide.topAnchor.constraint(equalTo: sampleMask.topAnchor, constant: ViewTraits.maskOffset).isActive = true
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

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
				y: ViewTraits.maskOffset,
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
}

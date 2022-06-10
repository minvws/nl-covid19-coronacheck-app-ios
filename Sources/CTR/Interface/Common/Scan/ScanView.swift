/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol HasScanView {
	var scanView: ScanView { get }
}

final class ScanView: BaseView {
	
	private struct ViewTraits {
		static let cornerRadius: CGFloat = 15
		static let margin: CGFloat = 20.0
		static let maskOffset: CGFloat = 100.0
	}
	
	let cameraView = UIView()
	let maskLayoutGuide = UILayoutGuide()
	
	private let maskLayoutGuideView: UIView = {

		let view = UIView()
		view.accessibilityIdentifier = "maskLayoutGuideView"
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = false
		view.backgroundColor = .yellow
		view.setContentCompressionResistancePriority(.required, for: .vertical)
		view.setContentHuggingPriority(.defaultLow, for: .vertical)
		return view
	}()
	
	private let backgroundView: UIView = {

		let view = UIView()
		view.accessibilityIdentifier = "backgroundView"
		view.backgroundColor = UIColor.red.withAlphaComponent(0.6)
		return view
	}()

	private lazy var maskLayoutGuideViewTopConstraint = maskLayoutGuideView.topAnchor.constraint(equalTo: topAnchor, constant: 167)

	init() {
		super.init(frame: .zero)

		NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: OperationQueue.main) { _ in
			self.setNeedsUpdateConstraints()
		}

		maskLayoutGuideViewTopConstraint.accessibilityLabel = "maskLayoutGuideViewTopConstraint"
		maskLayoutGuide.identifier = "MaskLayoutGuide"
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		cameraView.embed(in: self)
		cameraView.accessibilityIdentifier = "cameraView"
		backgroundView.embed(in: self)

		addSubview(maskLayoutGuideView)

		addLayoutGuide(maskLayoutGuide)
	}

	private func setupMaskLayoutGuideConstraints() {
		// The maskLayoutGuide pins itself to maskAutoLayoutGuideView, to act as guide for other views aligning to the mask.
		maskLayoutGuide.leftAnchor.constraint(equalTo: maskLayoutGuideView.leftAnchor, constant: 0).isActive = true
		maskLayoutGuide.rightAnchor.constraint(equalTo: maskLayoutGuideView.rightAnchor, constant: 0).isActive = true
		maskLayoutGuide.topAnchor.constraint(equalTo: maskLayoutGuideView.topAnchor, constant: 0).isActive = true
		maskLayoutGuide.bottomAnchor.constraint(equalTo: maskLayoutGuideView.bottomAnchor, constant: 0).isActive = true
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		setupMaskLayoutGuideConstraints()

		// First of all, pin maskLayoutGuideView to left/right/bottom. Top is special case (`maskLayoutGuideViewTopConstraint`), as adjusts based on rotation.
		maskLayoutGuideViewTopConstraint.isActive = true
		maskLayoutGuideView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 186).isActive = true
		maskLayoutGuideView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: 186).isActive = true
		maskLayoutGuideView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: 172).isActive = true

		// Next center it
		maskLayoutGuideView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

		// Make it square
		maskLayoutGuideView.heightAnchor.constraint(equalTo: maskLayoutGuideView.widthAnchor, multiplier: 1).isActive = true

		// Make the square the size of 55% of the shortest screen dimension:
		let shortestScreenDimension = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.50
		maskLayoutGuideView.heightAnchor.constraint(equalToConstant: shortestScreenDimension).isActive = true
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		// self.backgroundView.layer.mask = ScanView.calculateMaskLayer(fromView: self.maskLayoutGuideView, inSuperview: self)
	}

	override func updateConstraints() {
		super.updateConstraints()
		maskLayoutGuideViewTopConstraint.constant = UIScreen.main.bounds.height * 0.15
	}

	private static func calculateMaskLayer(fromView sampleMaskView: UIView, inSuperview superview: UIView) -> CALayer {

		// Path starts with full area of screen:
		let path = UIBezierPath(
			roundedRect: CGRect(
				x: 0,
				y: 0,
				width: superview.frame.size.width,
				height: superview.frame.size.height
			),
			cornerRadius: 0
		)

		// This is the viewfinder cutout
		let rectOfViewfinder = sampleMaskView.frame

		// Now stamp out the viewfinder cutout from the path:
		path.append(UIBezierPath(
			roundedRect: rectOfViewfinder,
			cornerRadius: ViewTraits.cornerRadius
		).reversing())

		// Create a shape to use, which is the full size of the screen:
		let rectLayer = CAShapeLayer()
		rectLayer.frame = CGRect(
			x: 0,
			y: 0,
			width: superview.frame.size.width,
			height: superview.frame.size.height
		)
		// Set the path of the shape to be our template `path`
		rectLayer.path = path.cgPath

		let maskLayer = CALayer()
		maskLayer.frame = sampleMaskView.bounds
		maskLayer.addSublayer(rectLayer)

		return maskLayer
	}
}

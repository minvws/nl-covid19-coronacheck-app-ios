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

		static let viewfinderBottomMargin: CGFloat = 170
		static let viewfinderMinimumHorizontalMargin: CGFloat = 20
		static let viewFinderMaximumSquareLength: CGFloat = 650
		static let viewFinderiPadMaxPercentageOfShortestScreenDimension: CGFloat = 0.6
		static let viewFinderTopMarginPercentageOfScreenHeight: CGFloat = 0.15
	}
	
	let cameraView: UIView = {
		let view = UIView()
		view.accessibilityIdentifier = "cameraView"
		return view
	}()
	let maskLayoutGuide: UILayoutGuide = {
		let guide = UILayoutGuide()
		guide.identifier = "maskLayoutGuide"
		return guide
	}()
	
	static var shouldAllowCameraRotationForCurrentDevice: Bool {
		UIDevice.current.userInterfaceIdiom == .pad
	}

	/// When there is a interruption to the camera (e.g. iPad splitscreen is started), show this view over the top:
	private let cameraInterruptedCurtain: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.accessibilityIdentifier = "cameraInterruptedCurtain"
		view.isHidden = true
		return view
	}()
	
	private let viewfinderView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		view.setContentCompressionResistancePriority(.required, for: .vertical)
		return view
	}()
	
	private let backgroundView: UIView = {

		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		return view
	}()

	private lazy var viewfinderTopConstraint = viewfinderView.topAnchor.constraint(equalTo: topAnchor, constant: 167)

	init() {
		super.init(frame: .zero)

		NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
			self?.setNeedsUpdateConstraints()
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		cameraView.embed(in: self)
		cameraInterruptedCurtain.embed(in: self)
		backgroundView.embed(in: self)

		addSubview(viewfinderView)

		addLayoutGuide(maskLayoutGuide)
	}

	override func setupViewConstraints() {
		super.setupViewConstraints()
		setupMaskLayoutGuideConstraints()
		setupViewfinderConstraints()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		backgroundView.layer.mask = ScanView.calculateMaskLayer(fromView: self.viewfinderView, inSuperview: self)
	}

	override func updateConstraints() {
		super.updateConstraints()
		viewfinderTopConstraint.constant = UIScreen.main.bounds.height * ViewTraits.viewFinderTopMarginPercentageOfScreenHeight
	}
	
	private func setupMaskLayoutGuideConstraints() {
		// The maskLayoutGuide pins itself to maskAutoLayoutGuideView, to act as guide for other views aligning to the mask.
		maskLayoutGuide.leftAnchor.constraint(equalTo: viewfinderView.leftAnchor, constant: 0).isActive = true
		maskLayoutGuide.rightAnchor.constraint(equalTo: viewfinderView.rightAnchor, constant: 0).isActive = true
		maskLayoutGuide.topAnchor.constraint(equalTo: viewfinderView.topAnchor, constant: 0).isActive = true
		maskLayoutGuide.bottomAnchor.constraint(equalTo: viewfinderView.bottomAnchor, constant: 0).isActive = true
	}
	
	private func setupViewfinderConstraints() {
		// First of all, activate top constraint, which adjusts based on rotation.
		viewfinderTopConstraint.isActive = true
		
		// Bottom shouldn't get too close to bottom of screen:
		viewfinderView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: ViewTraits.viewfinderBottomMargin).isActive = true
		
		// Left and Right have a required minimum border (which can grow)
		viewfinderView.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: ViewTraits.viewfinderMinimumHorizontalMargin).isActive = true
		viewfinderView.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: ViewTraits.viewfinderMinimumHorizontalMargin).isActive = true
		
		// It should always be square:
		viewfinderView.heightAnchor.constraint(equalTo: viewfinderView.widthAnchor, multiplier: 1).isActive = true
		
		// It should always be x-centered
		viewfinderView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		
		// It should have a max-width of 650pt
		viewfinderView.heightAnchor.constraint(lessThanOrEqualToConstant: ViewTraits.viewFinderMaximumSquareLength).isActive = true
		
		// On iPad, make the square side max 60% of the shortest screen dimension:
		if UIDevice.current.userInterfaceIdiom == .pad {
			let shortestScreenDimension = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
			let max60PercentOfScreenHeight = viewfinderView.heightAnchor.constraint(
				lessThanOrEqualToConstant: shortestScreenDimension * ViewTraits.viewFinderiPadMaxPercentageOfShortestScreenDimension
			)
			max60PercentOfScreenHeight.priority = .defaultHigh
			max60PercentOfScreenHeight.isActive = true
		}
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
	
	var shouldShowCurtain: Bool = false {
		didSet {
			cameraInterruptedCurtain.isHidden = !shouldShowCurtain
		}
	}
}

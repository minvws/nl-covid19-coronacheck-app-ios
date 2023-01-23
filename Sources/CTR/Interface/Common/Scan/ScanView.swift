/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

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
		
		static let cameraInterruptedTextInsets = UIEdgeInsets(top: 60, left: 30, bottom: 60, right: 30)
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
		view.backgroundColor = UIColor.black // completely obscure the frozen image
		view.accessibilityIdentifier = "cameraInterruptedCurtain"
		view.isHidden = true
		return view
	}()
	
	private let cameraInterruptedMessageView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(white: 0.2, alpha: 1)
		view.accessibilityIdentifier = "cameraInterruptedMessage"
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()
	
	private let cameraInterruptedMessageLabel: UILabel = {
		let label = Label(bodyBold: "Camera is alleen te gebruiken in volledig scherm. Sluit je vensterweergave.", textColor: C.white()!)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.accessibilityIdentifier = "cameraInterruptedMessageText"
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
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
		addSubview(cameraInterruptedMessageView)
		cameraInterruptedMessageLabel.embed(in: cameraInterruptedMessageView, insets: ViewTraits.cameraInterruptedTextInsets)
		backgroundView.embed(in: self)

		addSubview(viewfinderView)

		addLayoutGuide(maskLayoutGuide)
	}

	override func setupViewConstraints() {
		super.setupViewConstraints()
		setupMaskLayoutGuideConstraints()
		setupViewfinderConstraints()
		setupCameraInterruptedConstraints()
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
		maskLayoutGuide.leadingAnchor.constraint(equalTo: viewfinderView.leadingAnchor, constant: 0).isActive = true
		maskLayoutGuide.trailingAnchor.constraint(equalTo: viewfinderView.trailingAnchor, constant: 0).isActive = true
		maskLayoutGuide.topAnchor.constraint(equalTo: viewfinderView.topAnchor, constant: 0).isActive = true
		maskLayoutGuide.bottomAnchor.constraint(equalTo: viewfinderView.bottomAnchor, constant: 0).isActive = true
	}
	
	private func setupViewfinderConstraints() {
		// First of all, activate top constraint, which adjusts based on rotation.
		viewfinderTopConstraint.isActive = true
		
		// Bottom shouldn't get too close to bottom of screen:
		viewfinderView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: ViewTraits.viewfinderBottomMargin).isActive = true
		
		// Left and Right have a required minimum border (which can grow)
		viewfinderView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: ViewTraits.viewfinderMinimumHorizontalMargin).isActive = true
		viewfinderView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: ViewTraits.viewfinderMinimumHorizontalMargin).isActive = true
		
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
	
	private func setupCameraInterruptedConstraints() {
		cameraInterruptedMessageView.leadingAnchor.constraint(equalTo: maskLayoutGuide.leadingAnchor, constant: 0).isActive = true
		cameraInterruptedMessageView.trailingAnchor.constraint(equalTo: maskLayoutGuide.trailingAnchor, constant: 0).isActive = true
		cameraInterruptedMessageView.topAnchor.constraint(equalTo: maskLayoutGuide.topAnchor, constant: 0).isActive = true
		cameraInterruptedMessageView.bottomAnchor.constraint(equalTo: maskLayoutGuide.bottomAnchor, constant: 0).isActive = true
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
			cameraInterruptedMessageView.isHidden = !shouldShowCurtain
		}
	}
}

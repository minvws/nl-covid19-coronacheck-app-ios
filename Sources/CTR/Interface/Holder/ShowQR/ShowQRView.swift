/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class ShowQRView: BaseView {

	/// The display constants
	private struct ViewTraits {
		
		enum Dimension {
			static let titleLineHeight: CGFloat = 22
		}

		enum Margin {
			static let edge: CGFloat = 10
			static let infoEdge: CGFloat = 20
			static var domesticSecurity: CGFloat {
				SecurityAnimation.isWithinWinterPeriod ? 57 : 56
			}
			static var internationalSecurity: CGFloat {
				SecurityAnimation.isWithinWinterPeriod ? 90 : 52
			}
			static var internationalSecurityExtraSafeAreaInset: CGFloat {
				SecurityAnimation.isWithinWinterPeriod ? 60 : 20
			}
			static let returnToThirdPartyAppButton: CGFloat = 12
		}
		enum Spacing {
			static let buttonToPageControl: CGFloat = 4
			static let containerToReturnToThirdPartyAppButton: CGFloat = 24
		}
	}

	private var securityViewBottomConstraint: NSLayoutConstraint?

	/// The container for the the QR view controllers
	let containerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The control buttons
	let pageControl: PageControl = {

		let view = PageControl()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The security features
	let securityAnimationView: SecurityFeaturesView = {

		let view = SecurityFeaturesView()
		view.contentMode = .bottom
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let returnToThirdPartyAppButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		return button
	}()
	
	let navigationInfoView: ShowQRNavigationInfoView = {
		
		let view = ShowQRNavigationInfoView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		
		returnToThirdPartyAppButton.touchUpInside(self, action: #selector(didTapThirdPartyAppButton))
		navigationInfoView.previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
		navigationInfoView.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
		
		NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
			self?.setNeedsUpdateConstraints()
		}
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(securityAnimationView)
		addSubview(containerView)
		addSubview(pageControl)
		addSubview(returnToThirdPartyAppButton)
		addSubview(navigationInfoView)
		
		addLayoutGuide(qrFrameLayoutGuide)
		qrFrameLayoutGuide.identifier = "qrFrameLayoutGuide"
	}
	
	var qrFrameLayoutGuide: UILayoutGuide = UILayoutGuide()

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		setupContainerViewConstraints()
		setupSecurityViewConstraints()

		NSLayoutConstraint.activate([
			returnToThirdPartyAppButton.topAnchor.constraint(
				equalTo: containerView.bottomAnchor,
				constant: ViewTraits.Spacing.containerToReturnToThirdPartyAppButton
			),
			returnToThirdPartyAppButton.leadingAnchor.constraint(
				equalTo: containerView.leadingAnchor,
				constant: ViewTraits.Margin.returnToThirdPartyAppButton
			),
			
			qrFrameLayoutGuide.topAnchor.constraint(equalTo: containerView.topAnchor),
			qrFrameLayoutGuide.widthAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1.03),
			qrFrameLayoutGuide.heightAnchor.constraint(equalTo: containerView.heightAnchor),
			qrFrameLayoutGuide.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
			
			navigationInfoView.topAnchor.constraint(
				equalTo: containerView.bottomAnchor,
				constant: 2
			),
			navigationInfoView.leadingAnchor.constraint(
				equalTo: qrFrameLayoutGuide.leadingAnchor
			),
			
			navigationInfoView.trailingAnchor.constraint(
				equalTo: qrFrameLayoutGuide.trailingAnchor
			),
			
			pageControl.topAnchor.constraint(
				equalTo: navigationInfoView.bottomAnchor,
				constant: ViewTraits.Spacing.buttonToPageControl
			),
			pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
	
	private func setupContainerViewConstraints() {
		
		NSLayoutConstraint.activate([

			// QR View
			containerView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.Margin.edge
			),
			containerView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor
			),
			containerView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor
			),
			containerView.heightAnchor.constraint(lessThanOrEqualTo: widthAnchor)
		])
		
		containerHeightRestrictionConstraint = containerView.heightAnchor.constraint(lessThanOrEqualToConstant: containerHeightRestrictionConstant)
		containerHeightRestrictionConstraint?.isActive = true
		
		// On iPhone, the QR should be the full-width:
		if UIDevice.current.userInterfaceIdiom == .phone {
			containerView.heightAnchor.constraint(equalTo: widthAnchor).isActive = true
		}
	}
	
	var containerHeightRestrictionConstraint: NSLayoutConstraint?
	var containerHeightRestrictionConstant: CGFloat {
		let smallestDimension = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
		let ratio = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? 0.50 : 0.65
		return ratio * smallestDimension
	}

	private func setupSecurityViewConstraints() {
		
		NSLayoutConstraint.activate([
			// Security
			securityAnimationView.widthAnchor.constraint(equalTo: widthAnchor),
			securityAnimationView.widthAnchor.constraint(equalTo: securityAnimationView.heightAnchor, multiplier: 1.34), // the animation is not quite square
			securityAnimationView.centerXAnchor.constraint(equalTo: securityAnimationView.centerXAnchor),
			{
				let constraint = securityAnimationView.bottomAnchor.constraint(
					greaterThanOrEqualTo: bottomAnchor,
					constant: 0//ViewTraits.Margin.domesticSecurity
				)
				securityViewBottomConstraint = constraint
				return constraint
			}(),
			securityAnimationView.topAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: -300)
		])
	}
	
	override func safeAreaInsetsDidChange() {
		super.safeAreaInsetsDidChange()
		guard securityAnimationView.currentAnimation == .internationalAnimation, safeAreaInsets.bottom > 0 else { return }
//		securityViewBottomConstraint?.constant = safeAreaInsets.bottom + ViewTraits.Margin.internationalSecurityExtraSafeAreaInset
	}
	
	override func updateConstraints() {
		super.updateConstraints()
		containerHeightRestrictionConstraint?.constant = containerHeightRestrictionConstant
	}

	@objc func didTapThirdPartyAppButton() {

		didTapThirdPartyAppButtonCommand?()
	}

	@objc func didTapPreviousButton() {

		didTapPreviousButtonCommand?()
	}

	@objc func didTapNextButton() {

		didTapNextButtonCommand?()
	}

	// MARK: Public Access
	
	/// The dosage
	var dosage: String? {
		didSet {
			navigationInfoView.dosageLabel.attributedText = dosage?.setLineHeight(ViewTraits.Dimension.titleLineHeight, alignment: .center)
		}
	}

	var returnToThirdPartyAppButtonTitle: String? {
		didSet {
			returnToThirdPartyAppButton.title = returnToThirdPartyAppButtonTitle
			returnToThirdPartyAppButton.isHidden = returnToThirdPartyAppButtonTitle == nil
		}
	}
	
	var pageButtonAccessibility: (previous: String, next: String)? {
		didSet {
			navigationInfoView.previousButton.accessibilityLabel = pageButtonAccessibility?.previous
			navigationInfoView.nextButton.accessibilityLabel = pageButtonAccessibility?.next
		}
	}

	var didTapThirdPartyAppButtonCommand: (() -> Void)?

	var didTapPreviousButtonCommand: (() -> Void)?

	var didTapNextButtonCommand: (() -> Void)?

	/// Play the animation
	func play() {

		securityAnimationView.play()
	}

	/// Resume the animation
	func resume() {

		securityAnimationView.resume()
	}

	func setupForInternational() {

		securityAnimationView.setupForInternational()
//		securityViewBottomConstraint?.constant = ViewTraits.Margin.internationalSecurity
	}
}

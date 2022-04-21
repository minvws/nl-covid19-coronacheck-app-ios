/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
			static let buttonToPageControl: CGFloat = 16
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
	let securityView: SecurityFeaturesView = {

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

	/// The scrollview
	let scrollView: UIScrollView = {

		let view = UIScrollView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The info label
	private let infoLabel: Label = {

		return Label(body: nil).multiline()
	}()

	private let scrollContentView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = C.white()?.withAlphaComponent(0.8)
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		
		returnToThirdPartyAppButton.touchUpInside(self, action: #selector(didTapThirdPartyAppButton))
		navigationInfoView.previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
		navigationInfoView.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)

		// ScrollView is blocking the Security Animation Reversal
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
		scrollView.addGestureRecognizer(tapGesture)
	}

	@objc func scrollViewTapped() {
		// Reverse the security animation
		securityView.primaryButtonTapped()
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(securityView)
		addSubview(containerView)
		addSubview(pageControl)
		addSubview(returnToThirdPartyAppButton)
		addSubview(navigationInfoView)
		addSubview(scrollView)
		scrollView.addSubview(scrollContentView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

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
			containerView.heightAnchor.constraint(equalTo: widthAnchor),

			pageControl.topAnchor.constraint(
				equalTo: navigationInfoView.bottomAnchor,
				constant: ViewTraits.Spacing.buttonToPageControl
			),
			pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),

			// Security
			securityView.heightAnchor.constraint(equalTo: securityView.widthAnchor),
			securityView.leadingAnchor.constraint(equalTo: leadingAnchor),
			securityView.trailingAnchor.constraint(equalTo: trailingAnchor),

			returnToThirdPartyAppButton.topAnchor.constraint(
				equalTo: containerView.bottomAnchor,
				constant: ViewTraits.Spacing.containerToReturnToThirdPartyAppButton
			),
			returnToThirdPartyAppButton.leadingAnchor.constraint(
				equalTo: containerView.leadingAnchor,
				constant: ViewTraits.Margin.returnToThirdPartyAppButton
			),
			
			navigationInfoView.topAnchor.constraint(
				equalTo: containerView.bottomAnchor
			),
			navigationInfoView.leadingAnchor.constraint(
				greaterThanOrEqualTo: containerView.leadingAnchor
			),
			navigationInfoView.trailingAnchor.constraint(
				lessThanOrEqualTo: containerView.trailingAnchor
			)
		])

		securityViewBottomConstraint = securityView.bottomAnchor.constraint(
			equalTo: bottomAnchor,
			constant: ViewTraits.Margin.domesticSecurity
		)
		securityViewBottomConstraint?.isActive = true

		bringSubviewToFront(containerView)
		bringSubviewToFront(navigationInfoView)

		setupScrollViewConstraints()
	}

	func setupScrollViewConstraints() {

		infoLabel.embed(
			in: scrollContentView,
			insets: UIEdgeInsets(
				top: 0,
				left: ViewTraits.Margin.infoEdge,
				bottom: ViewTraits.Margin.infoEdge,
				right: ViewTraits.Margin.infoEdge
			)
		)

		NSLayoutConstraint.activate([
			scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			scrollContentView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
			scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			scrollContentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

			scrollView.topAnchor.constraint(equalTo: pageControl.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
		bringSubviewToFront(scrollView)
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
        
		securityView.primaryButton.isAccessibilityElement = false
	}
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        guard securityView.currentAnimation == .internationalAnimation, safeAreaInsets.bottom > 0 else { return }
        securityViewBottomConstraint?.constant = safeAreaInsets.bottom + ViewTraits.Margin.internationalSecurityExtraSafeAreaInset
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

	/// The info
	var info: String? {
		didSet {
			infoLabel.attributedText = info?.setLineHeight(ViewTraits.Dimension.titleLineHeight, alignment: .center)
			scrollView.isHidden = info == nil
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

		securityView.play()
	}

	/// Resume the animation
	func resume() {

		securityView.resume()
	}

	func setupForInternational() {

		securityView.setupForInternational()
		securityViewBottomConstraint?.constant = ViewTraits.Margin.internationalSecurity
	}
}

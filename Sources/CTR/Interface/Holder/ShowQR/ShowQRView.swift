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
			static let pageButton: CGFloat = 60
		}

		enum Margin {
			static let edge: CGFloat = 10
			static let infoEdge: CGFloat = 20
			static let domesticSecurity: CGFloat = 56
			static let internationalSecurity: CGFloat = 49
			static let returnToThirdPartyAppButton: CGFloat = 4
		}
		enum Spacing {
			static let dosageToButton: CGFloat = 10
			static let buttonToPageControl: CGFloat = 10
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
	let pageControl: UIPageControl = {

		let view = UIPageControl()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.pageIndicatorTintColor = Theme.colors.grey2
		view.currentPageIndicatorTintColor = Theme.colors.primary
		view.hidesForSinglePage = true
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

	/// The info button
	let nextButton: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(I.pageIndicatorNext(), for: .normal)
		return button
	}()

	/// The info button
	let previousButton: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(I.pageIndicatorBack(), for: .normal)
		return button
	}()
	
	/// The title label
	private let dosageLabel: Label = {

		return Label(headlineBold: nil, montserrat: true).multiline()
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

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		infoLabel.backgroundColor = Theme.colors.viewControllerBackground.withAlphaComponent(0.8)
		
		returnToThirdPartyAppButton.touchUpInside(self, action: #selector(didTapThirdPartyAppButton))
		previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
		nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)

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
		addSubview(nextButton)
		addSubview(previousButton)
		addSubview(dosageLabel)
		addSubview(scrollView)
		scrollView.addSubview(infoLabel)
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
				equalTo: dosageLabel.bottomAnchor,
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

			nextButton.widthAnchor.constraint(equalToConstant: ViewTraits.Dimension.pageButton),
			nextButton.heightAnchor.constraint(equalToConstant: ViewTraits.Dimension.pageButton),
			nextButton.centerYAnchor.constraint(equalTo: dosageLabel.centerYAnchor),
			nextButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

			previousButton.widthAnchor.constraint(equalToConstant: ViewTraits.Dimension.pageButton),
			previousButton.heightAnchor.constraint(equalToConstant: ViewTraits.Dimension.pageButton),
			previousButton.centerYAnchor.constraint(equalTo: dosageLabel.centerYAnchor),
			previousButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			
			dosageLabel.topAnchor.constraint(
				equalTo: containerView.bottomAnchor
			),
			dosageLabel.leadingAnchor.constraint(
				greaterThanOrEqualTo: previousButton.trailingAnchor,
				constant: ViewTraits.Spacing.dosageToButton
			),
			dosageLabel.trailingAnchor.constraint(
				lessThanOrEqualTo: nextButton.leadingAnchor,
				constant: -ViewTraits.Spacing.dosageToButton
			),
			dosageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

			infoLabel.topAnchor.constraint( equalTo: scrollView.topAnchor),
			infoLabel.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.infoEdge
			),
			infoLabel.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.Margin.infoEdge
			),
			// Extra constraints to make the infoLabel scrollable
			infoLabel.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.Margin.infoEdge
			),
			infoLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			infoLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),

			scrollView.topAnchor.constraint(equalTo: pageControl.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		securityViewBottomConstraint = securityView.bottomAnchor.constraint(
			equalTo: bottomAnchor,
			constant: ViewTraits.Margin.domesticSecurity
		)
		securityViewBottomConstraint?.isActive = true

		bringSubviewToFront(containerView)
		bringSubviewToFront(nextButton)
		bringSubviewToFront(previousButton)
		bringSubviewToFront(dosageLabel)
		bringSubviewToFront(scrollView)
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
        
        accessibilityElements = [containerView]
	}

	@objc func didTapThirdPartyAppButton() {

		didTapPreviousButtonCommand?()
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
			dosageLabel.attributedText = dosage?.setLineHeight(ViewTraits.Dimension.titleLineHeight, alignment: .center)
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

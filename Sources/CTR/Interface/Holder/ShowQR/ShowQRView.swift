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

		// Margins
		static let margin: CGFloat = 10.0
		static let domesticSecurityMargin: CGFloat = 56.0
		static let internationalSecurityMargin: CGFloat = 49.0
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

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		returnToThirdPartyAppButton.touchUpInside(self, action: #selector(didTapThirdPartyAppButton))
		previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
		nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
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
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// QR View
			containerView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.margin
			),
//			containerView.heightAnchor.constraint(greaterThanOrEqualTo: containerView.widthAnchor), // Might need to go
			containerView.heightAnchor.constraint(equalToConstant: 430),
			containerView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor
			),
			containerView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor
			),

			pageControl.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
			pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),

			// Security
			securityView.heightAnchor.constraint(equalTo: securityView.widthAnchor),
			securityView.leadingAnchor.constraint(equalTo: leadingAnchor),
			securityView.trailingAnchor.constraint(equalTo: trailingAnchor),

			returnToThirdPartyAppButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 24),
			returnToThirdPartyAppButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),

			nextButton.widthAnchor.constraint(equalToConstant: 60),
			nextButton.heightAnchor.constraint(equalToConstant: 60),
			nextButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			nextButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

			previousButton.widthAnchor.constraint(equalToConstant: 60),
			previousButton.heightAnchor.constraint(equalToConstant: 60),
			previousButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			previousButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
		])

		securityViewBottomConstraint = securityView.bottomAnchor.constraint(
			equalTo: bottomAnchor,
			constant: ViewTraits.domesticSecurityMargin
		)
		securityViewBottomConstraint?.isActive = true

		bringSubviewToFront(containerView)
		bringSubviewToFront(nextButton)
		bringSubviewToFront(previousButton)
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
		securityViewBottomConstraint?.constant = ViewTraits.internationalSecurityMargin
	}
}

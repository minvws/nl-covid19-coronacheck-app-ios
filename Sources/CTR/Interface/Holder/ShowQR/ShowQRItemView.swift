/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class ShowQRItemView: BaseView {

	enum VisibilityState: Equatable {
		case loading
		case visible(qrImage: UIImage)
		case hiddenForScreenCapture
		case screenshotBlocking(timeRemainingText: String, voiceoverTimeRemainingText: String)

		var isVisible: Bool {
			if case .visible = self { return true }
			return false
		}
	}
	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 10.0
		static let domesticSecurityMargin: CGFloat = 56.0
		static let internationalSecurityMargin: CGFloat = 49.0
	}

	private var securityViewBottomConstraint: NSLayoutConstraint?

	/// The spinner
	private let spinner: UIActivityIndicatorView = {

		let view = UIActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 13.0, *) {
			view.style = .large
		} else {
			view.style = .whiteLarge
		}
		view.color = Theme.colors.primary
		view.hidesWhenStopped = true
		return view
	}()

	/// The image view for the QR image
	let largeQRimageView: UIImageView = {

		let view = UIImageView()
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

	private let screenshotBlockingView: ShowQRScreenshotBlockingView = {

		let view = ShowQRScreenshotBlockingView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		returnToThirdPartyAppButton.touchUpInside(self, action: #selector(didTapThirdPartyAppButton))
		spinner.startAnimating()
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(securityView)
		addSubview(spinner)
		addSubview(largeQRimageView)
		addSubview(returnToThirdPartyAppButton)
		addSubview(screenshotBlockingView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// QR View
			largeQRimageView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.margin
			),
			largeQRimageView.heightAnchor.constraint(equalTo: largeQRimageView.widthAnchor),
			largeQRimageView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			),
			largeQRimageView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.margin
			),

			screenshotBlockingView.leadingAnchor.constraint(equalTo: largeQRimageView.leadingAnchor),
			screenshotBlockingView.trailingAnchor.constraint(equalTo: largeQRimageView.trailingAnchor),
			screenshotBlockingView.topAnchor.constraint(equalTo: largeQRimageView.topAnchor),
			screenshotBlockingView.bottomAnchor.constraint(equalTo: largeQRimageView.bottomAnchor),

			spinner.centerYAnchor.constraint(equalTo: largeQRimageView.centerYAnchor),
			spinner.centerXAnchor.constraint(equalTo: largeQRimageView.centerXAnchor),

			// Security
			securityView.heightAnchor.constraint(equalTo: securityView.widthAnchor),
			securityView.leadingAnchor.constraint(equalTo: leadingAnchor),
			securityView.trailingAnchor.constraint(equalTo: trailingAnchor),

			returnToThirdPartyAppButton.topAnchor.constraint(equalTo: largeQRimageView.bottomAnchor, constant: 24),
			returnToThirdPartyAppButton.leadingAnchor.constraint(equalTo: largeQRimageView.leadingAnchor, constant: 4)
		])

		securityViewBottomConstraint = securityView.bottomAnchor.constraint(
			equalTo: bottomAnchor,
			constant: ViewTraits.domesticSecurityMargin
		)
		securityViewBottomConstraint?.isActive = true

		bringSubviewToFront(largeQRimageView)
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()

        largeQRimageView.isAccessibilityElement = true
        largeQRimageView.accessibilityTraits = .image
        
        accessibilityElements = [largeQRimageView]
	}

	@objc func didTapThirdPartyAppButton() {

		didTapThirdPartyAppButtonCommand?()
	}

	// MARK: Public Access

	var visibilityState: VisibilityState = .loading {
		didSet {

			switch visibilityState {
				case .hiddenForScreenCapture:
					returnToThirdPartyAppButton.isHidden = true
					spinner.stopAnimating()
					largeQRimageView.isHidden = true
					screenshotBlockingView.isHidden = true
					spinner.isHidden = true

				case .loading:
					returnToThirdPartyAppButton.isHidden = true
					spinner.startAnimating()
					largeQRimageView.isHidden = true
					screenshotBlockingView.isHidden = true
					spinner.isHidden = false
                    
				case .screenshotBlocking(let timeRemainingText, let voiceoverTimeRemainingText):
					spinner.stopAnimating()
					returnToThirdPartyAppButton.isHidden = true
					largeQRimageView.isHidden = true
					screenshotBlockingView.setCountdown(text: timeRemainingText, voiceoverText: voiceoverTimeRemainingText)
					screenshotBlockingView.isHidden = false
					spinner.isHidden = true

				case .visible(let qrImage):
					returnToThirdPartyAppButton.isHidden = returnToThirdPartyAppButtonTitle == nil
					spinner.stopAnimating()
					largeQRimageView.isHidden = false
					largeQRimageView.image = qrImage
					screenshotBlockingView.isHidden = true
					spinner.isHidden = true
			}

			// Update accessibility at the moment that it becomes .screenshotBlocking from another state:
			switch (oldValue, visibilityState) {
				case (.screenshotBlocking, .screenshotBlocking): break // ignore
				case (_, .screenshotBlocking):
					accessibilityElements = [screenshotBlockingView]

					UIAccessibility.post(notification: .layoutChanged, argument: screenshotBlockingView)

					DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
						UIAccessibility.post(
							notification: .announcement,
							argument: L.holderShowqrScreenshotwarningTitle()
						)
					}
				default: break
			}
		}
	}

	/// The accessibility description
	var accessibilityDescription: String? {
		didSet {
            largeQRimageView.accessibilityLabel = accessibilityDescription
		}
	}

	var returnToThirdPartyAppButtonTitle: String? {
		didSet {
			returnToThirdPartyAppButton.title = returnToThirdPartyAppButtonTitle
			returnToThirdPartyAppButton.isHidden = returnToThirdPartyAppButtonTitle == nil || !self.visibilityState.isVisible
		}
	}

	var didTapThirdPartyAppButtonCommand: (() -> Void)?

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

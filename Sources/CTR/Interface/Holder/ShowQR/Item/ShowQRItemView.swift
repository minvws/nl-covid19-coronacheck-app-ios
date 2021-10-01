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

		// Dimensions
		static let titleLineHeight: CGFloat = 22

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

	/// The title label
	private let titleLabel: Label = {

		return Label(headlineBold: nil, montserrat: true).multiline()
	}()

	private let screenshotBlockingView: ShowQRScreenshotBlockingView = {

		let view = ShowQRScreenshotBlockingView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		spinner.startAnimating()
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(spinner)
		addSubview(largeQRimageView)
		addSubview(screenshotBlockingView)
		addSubview(titleLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// QR View
			largeQRimageView.topAnchor.constraint(equalTo: topAnchor),
			largeQRimageView.heightAnchor.constraint(equalTo: largeQRimageView.widthAnchor),
			largeQRimageView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			largeQRimageView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			titleLabel.topAnchor.constraint(
				equalTo: largeQRimageView.bottomAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.margin
			),

			screenshotBlockingView.leadingAnchor.constraint(equalTo: largeQRimageView.leadingAnchor),
			screenshotBlockingView.trailingAnchor.constraint(equalTo: largeQRimageView.trailingAnchor),
			screenshotBlockingView.topAnchor.constraint(equalTo: largeQRimageView.topAnchor),
			screenshotBlockingView.bottomAnchor.constraint(equalTo: largeQRimageView.bottomAnchor),

			spinner.centerYAnchor.constraint(equalTo: largeQRimageView.centerYAnchor),
			spinner.centerXAnchor.constraint(equalTo: largeQRimageView.centerXAnchor)
		])
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()

        largeQRimageView.isAccessibilityElement = true
        largeQRimageView.accessibilityTraits = .image
		titleLabel.isAccessibilityElement = true
        
        accessibilityElements = [largeQRimageView, titleLabel]
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight, alignment: .center)
		}
	}

	var visibilityState: VisibilityState = .loading {
		didSet {

			switch visibilityState {
				case .hiddenForScreenCapture:
					spinner.stopAnimating()
					largeQRimageView.isHidden = true
					screenshotBlockingView.isHidden = true
					titleLabel.isHidden = true
					spinner.isHidden = true

				case .loading:
					spinner.startAnimating()
					largeQRimageView.isHidden = true
					screenshotBlockingView.isHidden = true
					titleLabel.isHidden = false
					spinner.isHidden = false
                    
				case .screenshotBlocking(let timeRemainingText, let voiceoverTimeRemainingText):
					spinner.stopAnimating()
					largeQRimageView.isHidden = true
					screenshotBlockingView.setCountdown(text: timeRemainingText, voiceoverText: voiceoverTimeRemainingText)
					screenshotBlockingView.isHidden = false
					titleLabel.isHidden = true
					spinner.isHidden = true

				case .visible(let qrImage):
					spinner.stopAnimating()
					largeQRimageView.isHidden = false
					largeQRimageView.image = qrImage
					screenshotBlockingView.isHidden = true
					titleLabel.isHidden = false
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
}

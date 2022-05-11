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
		case irrelevant(qrImage: UIImage)
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
	}

	private let activityIndicatorView: ActivityIndicatorView = {
		
		let view = ActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The image view for the QR image
	let largeQRimageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let screenshotBlockingView: ShowQRScreenshotBlockingView = {

		let view = ShowQRScreenshotBlockingView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let irrelevantView: ShowQRIrrelevantView = {

		let view = ShowQRIrrelevantView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		activityIndicatorView.shouldShowLoadingSpinner = true
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(activityIndicatorView)
		addSubview(largeQRimageView)
		addSubview(screenshotBlockingView)
		addSubview(irrelevantView)
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
			largeQRimageView.bottomAnchor.constraint(
				lessThanOrEqualTo: bottomAnchor,
				constant: -ViewTraits.margin
			),

			screenshotBlockingView.leadingAnchor.constraint(equalTo: largeQRimageView.leadingAnchor),
			screenshotBlockingView.trailingAnchor.constraint(equalTo: largeQRimageView.trailingAnchor),
			screenshotBlockingView.topAnchor.constraint(equalTo: largeQRimageView.topAnchor),
			screenshotBlockingView.bottomAnchor.constraint(equalTo: largeQRimageView.bottomAnchor),

			irrelevantView.leadingAnchor.constraint(equalTo: largeQRimageView.leadingAnchor),
			irrelevantView.trailingAnchor.constraint(equalTo: largeQRimageView.trailingAnchor),
			irrelevantView.topAnchor.constraint(equalTo: largeQRimageView.topAnchor),
			irrelevantView.bottomAnchor.constraint(equalTo: largeQRimageView.bottomAnchor),

			activityIndicatorView.centerYAnchor.constraint(equalTo: largeQRimageView.centerYAnchor),
			activityIndicatorView.centerXAnchor.constraint(equalTo: largeQRimageView.centerXAnchor)
		])
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()

        largeQRimageView.isAccessibilityElement = true
        largeQRimageView.accessibilityTraits = .image
	}
	
	private func updateAccessibilityState(for view: UIView) {
		accessibilityElements = [view]
		UIAccessibility.post(notification: .layoutChanged, argument: view)
	}

	// MARK: Public Access

	var visibilityState: VisibilityState = .loading {
		didSet {

			switch visibilityState {
				case .hiddenForScreenCapture:
					activityIndicatorView.shouldShowLoadingSpinner = false
					largeQRimageView.isHidden = true
					screenshotBlockingView.isHidden = true
					irrelevantView.isHidden = true
					activityIndicatorView.isHidden = true

				case .loading:
					activityIndicatorView.shouldShowLoadingSpinner = true
					largeQRimageView.isHidden = true
					screenshotBlockingView.isHidden = true
					irrelevantView.isHidden = true
					activityIndicatorView.isHidden = false

				case .screenshotBlocking(let timeRemainingText, let voiceoverTimeRemainingText):
					activityIndicatorView.shouldShowLoadingSpinner = false
					largeQRimageView.isHidden = true
					screenshotBlockingView.setCountdown(text: timeRemainingText, voiceoverText: voiceoverTimeRemainingText)
					screenshotBlockingView.isHidden = false
					irrelevantView.isHidden = true
					activityIndicatorView.isHidden = true

				case .visible(let qrImage):
					activityIndicatorView.shouldShowLoadingSpinner = false
					largeQRimageView.isHidden = false
					largeQRimageView.image = qrImage
					screenshotBlockingView.isHidden = true
					irrelevantView.isHidden = true
					activityIndicatorView.isHidden = true

				case .irrelevant(let qrImage):
					activityIndicatorView.shouldShowLoadingSpinner = false
					largeQRimageView.isHidden = false
					largeQRimageView.image = qrImage
					screenshotBlockingView.isHidden = true
					irrelevantView.isHidden = false
					activityIndicatorView.isHidden = true
			}

			// Update accessibility at the moment that it becomes .screenshotBlocking from another state:
			switch (oldValue, visibilityState) {
				case (.screenshotBlocking, .screenshotBlocking),
					(.irrelevant, .irrelevant),
					(.visible, .visible): break // ignore
				case (_, .screenshotBlocking):
					updateAccessibilityState(for: screenshotBlockingView)

					DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
						UIAccessibility.post(
							notification: .announcement,
							argument: L.holderShowqrScreenshotwarningTitle()
						)
					}
				case (_, .irrelevant):
					updateAccessibilityState(for: irrelevantView)
				case (_, .visible):
					updateAccessibilityState(for: largeQRimageView)
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

/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class ShowQRItemView: BaseView {
	
	enum VisibilityState: Equatable {
		case loading
		case visible(qrImage: UIImage)
		case overlay(qrImage: UIImage)
		case hiddenForScreenCapture
		case screenshotBlocking(timeRemainingText: String, voiceoverTimeRemainingText: String)
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
		view.contentMode = .scaleAspectFit
		return view
	}()
	
	private let screenshotBlockingView: ShowQRScreenshotBlockingView = {
		
		let view = ShowQRScreenshotBlockingView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let overlayView: ShowQROverlayView = {
		
		let view = ShowQROverlayView()
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
		addSubview(overlayView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			// QR View
			largeQRimageView.topAnchor.constraint(equalTo: topAnchor),
			largeQRimageView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			largeQRimageView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			largeQRimageView.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.margin
			),
			
			screenshotBlockingView.leadingAnchor.constraint(equalTo: largeQRimageView.leadingAnchor),
			screenshotBlockingView.trailingAnchor.constraint(equalTo: largeQRimageView.trailingAnchor),
			screenshotBlockingView.topAnchor.constraint(equalTo: largeQRimageView.topAnchor),
			screenshotBlockingView.bottomAnchor.constraint(equalTo: largeQRimageView.bottomAnchor),
			
			overlayView.centerXAnchor.constraint(equalTo: largeQRimageView.centerXAnchor),
			overlayView.widthAnchor.constraint(equalTo: overlayView.heightAnchor),
			overlayView.topAnchor.constraint(equalTo: largeQRimageView.topAnchor),
			overlayView.bottomAnchor.constraint(equalTo: largeQRimageView.bottomAnchor),
			
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
					overlayView.isHidden = true
					activityIndicatorView.isHidden = true
					
				case .loading:
					activityIndicatorView.shouldShowLoadingSpinner = true
					largeQRimageView.isHidden = true
					screenshotBlockingView.isHidden = true
					overlayView.isHidden = true
					activityIndicatorView.isHidden = false
					
				case .screenshotBlocking(let timeRemainingText, let voiceoverTimeRemainingText):
					activityIndicatorView.shouldShowLoadingSpinner = false
					largeQRimageView.isHidden = true
					screenshotBlockingView.setCountdown(text: timeRemainingText, voiceoverText: voiceoverTimeRemainingText)
					screenshotBlockingView.isHidden = false
					overlayView.isHidden = true
					activityIndicatorView.isHidden = true
					
				case .visible(let qrImage):
					activityIndicatorView.shouldShowLoadingSpinner = false
					largeQRimageView.isHidden = false
					largeQRimageView.image = qrImage
					screenshotBlockingView.isHidden = true
					overlayView.isHidden = true
					activityIndicatorView.isHidden = true
					
				case .overlay(let qrImage):
					activityIndicatorView.shouldShowLoadingSpinner = false
					largeQRimageView.isHidden = false
					largeQRimageView.image = qrImage
					screenshotBlockingView.isHidden = true
					overlayView.isHidden = false
					activityIndicatorView.isHidden = true
			}
			
			// Update accessibility at the moment that it becomes .screenshotBlocking from another state:
			switch (oldValue, visibilityState) {
				case (.screenshotBlocking, .screenshotBlocking),
					(.overlay, .overlay),
					(.visible, .visible): break // ignore
				case (_, .screenshotBlocking):
					updateAccessibilityState(for: screenshotBlockingView)
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
						UIAccessibility.post(
							notification: .announcement,
							argument: L.holderShowqrScreenshotwarningTitle()
						)
					}
				case (_, .overlay):
					updateAccessibilityState(for: overlayView)
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

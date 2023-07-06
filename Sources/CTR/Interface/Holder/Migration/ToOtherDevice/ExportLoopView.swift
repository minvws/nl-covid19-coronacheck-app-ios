/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

class ExportLoopView: ScrolledStackWithButtonView {
	
	/// The display constants
	private struct ViewTraits {
		enum Image {
			static let bottomMargin: CGFloat = 10
		}
		enum Step {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let bottomMargin: CGFloat = 8.0
		}
		enum Header {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
			static let bottomMargin: CGFloat = 24.0
		}
		enum Orientation {
			static let landscape: CGFloat = 0.66
			static let portrait: CGFloat = 1
		}
		enum PageControl {
			static let spacing: CGFloat = 16.0
			static let spacingSmallScreen: CGFloat = 8.0
		}
	}
	
	private let containerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let stepLabel: Label = {

		return Label(bodySemiBold: nil)
	}()
	
	/// The title label
	private let headerLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()
	
	/// The title label
	private let messageLabel: TextView = {
		
		return TextView()
	}()
	
	/// The control buttons
	let pageControl: PageControl = {

		let view = PageControl()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private var containerHeightPortraitConstraint: NSLayoutConstraint?
	private var containerHeightLandscapeConstraint: NSLayoutConstraint?
	private var imageHeightPortraitConstraint: NSLayoutConstraint?
	private var imageHeightLandscapeConstraint: NSLayoutConstraint?
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		containerView.addSubview(imageView)
		stackView.addArrangedSubview(containerView)
		stackView.setCustomSpacing(ViewTraits.Image.bottomMargin, after: imageView)
		stackView.addArrangedSubview(stepLabel)
		stackView.setCustomSpacing(ViewTraits.Step.bottomMargin, after: stepLabel)
		stackView.addArrangedSubview(headerLabel)
		stackView.setCustomSpacing(ViewTraits.Header.bottomMargin, after: headerLabel)
		stackView.addArrangedSubview(messageLabel)
		
		footerButtonView.buttonStackView.alignment = .center
		footerButtonView.buttonStackView.insertArrangedSubview(pageControl, at: 0)
	}

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		stackView.distribution = .fill
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			containerView.widthAnchor.constraint(equalTo: stackView.widthAnchor),

			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
			imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
		])
		
		containerHeightPortraitConstraint = containerView.heightAnchor.constraint(
			equalTo: stackView.widthAnchor,
			multiplier: ViewTraits.Orientation.portrait
		)
		containerHeightLandscapeConstraint = containerView.heightAnchor.constraint(
			equalTo: stackView.widthAnchor,
			multiplier: ViewTraits.Orientation.landscape
		)
		
		imageHeightPortraitConstraint = imageView.heightAnchor.constraint(
			equalTo: stackView.widthAnchor,
			multiplier: ViewTraits.Orientation.portrait
		)
		imageHeightLandscapeConstraint = imageView.heightAnchor.constraint(
			equalTo: stackView.widthAnchor,
			multiplier: ViewTraits.Orientation.landscape
		)
		
		let smallOrLandscape = UIDevice.current.isSmallScreen || UIDevice.current.isLandscape
		footerButtonView.buttonStackView.spacing = smallOrLandscape ? ViewTraits.PageControl.spacingSmallScreen : ViewTraits.PageControl.spacing
		if smallOrLandscape {
			footerButtonView.topButtonConstraint?.constant = ViewTraits.PageControl.spacingSmallScreen
		}
	}

	// Public
	
	var step: String? {
		didSet {
			stepLabel.attributedText = step?.setLineHeight(
				ViewTraits.Step.lineHeight,
				kerning: ViewTraits.Step.kerning,
				textColor: C.primaryBlue()!
			)
		}
	}
	
	var header: String? {
		didSet {
			headerLabel.attributedText = header?.setLineHeight(
				ViewTraits.Header.lineHeight,
				kerning: ViewTraits.Header.kerning
			)
		}
	}
	
	var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(text: message, style: .bodyDark) {
				self.messageLabel.attributedText = $0
			}
		}
	}
	
	func layoutForOrientation(isLandScape: Bool) {

		guard UIDevice.current.userInterfaceIdiom != .phone else {
			
			containerHeightPortraitConstraint?.isActive = true
			containerHeightLandscapeConstraint?.isActive = false
			imageHeightPortraitConstraint?.isActive = true
			imageHeightLandscapeConstraint?.isActive = false
			return
		}
		
		containerHeightPortraitConstraint?.isActive = !isLandScape
		containerHeightLandscapeConstraint?.isActive = isLandScape
		imageHeightPortraitConstraint?.isActive = !isLandScape
		imageHeightLandscapeConstraint?.isActive = isLandScape
	}
}

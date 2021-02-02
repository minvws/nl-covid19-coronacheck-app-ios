/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let buttonHeight: CGFloat = 50
		
		// Margins
		static let margin: CGFloat = 16.0
		static let ribbonOffset: CGFloat = 15.0
		static let buttonOffset: CGFloat = 80.0
	}
	
	let ribbonView: UIImageView = {
		
		let view = UIImageView(image: .ribbon)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let imageContainerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let imageView: UIImageView = {
		
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()
	
	/// The title label
	let titleLabel: Label = {
		
		return Label(title1: nil).multiline()
	}()
	
	/// The message label
	let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()
	
	let pageControl: UIPageControl = {
		
		let view = UIPageControl()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.pageIndicatorTintColor = .lightGray
		view.currentPageIndicatorTintColor = .gray
		return view
	}()
	
	/// the update button
	let primaryButton: Button = {
		
		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	private var ribbonTopConstraint: NSLayoutConstraint?
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = .white
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(ribbonView)
		imageContainerView.addSubview(imageView)
		addSubview(imageContainerView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(pageControl)
		addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		ribbonTopConstraint = ribbonView.topAnchor.constraint(equalTo: topAnchor)
		ribbonTopConstraint?.constant = UIDevice.current.hasNotch ? ViewTraits.ribbonOffset : -ViewTraits.ribbonOffset
		ribbonTopConstraint?.isActive = true
		
		NSLayoutConstraint.activate([
			
			// Ribbon
			ribbonView.centerXAnchor.constraint(equalTo: centerXAnchor),

			// ImageContainer
			imageContainerView.topAnchor.constraint(equalTo: ribbonView.bottomAnchor),
			imageContainerView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),
			imageContainerView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin),
			imageContainerView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Image
			imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
			imageView.leadingAnchor.constraint(
				equalTo: imageContainerView.leadingAnchor,
				constant: ViewTraits.margin),
			imageView.trailingAnchor.constraint(
				equalTo: imageContainerView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			
			// Title
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.margin
			),
			
			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			messageLabel.bottomAnchor.constraint(
				equalTo: pageControl.topAnchor,
				constant: -ViewTraits.margin
			),
			
			// Page Control
			pageControl.bottomAnchor.constraint(
				equalTo: primaryButton.topAnchor,
				constant: -ViewTraits.margin)
			,
			pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
			
			// Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.buttonOffset
			),
			primaryButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.buttonOffset
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}
}

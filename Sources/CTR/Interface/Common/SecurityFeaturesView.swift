/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Lottie

class SecurityFeaturesView: BaseView, Logging {

	var loggingCategory: String = "SecurityFeaturesView"

	private var animatingLeftToRight = true

	/// The animation view
	private let animationView: AnimationView = {

		let view = AnimationView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundBehavior = .pauseAndRestore
		view.respectAnimationFrameRate = true
		return view
	}()

	/// The image view for the background image
	private let backgroundImageView: UIImageView = {

		let view = UIImageView()
		view.image = .securityBackground
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// the button
	internal let primaryButton: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// The current animation
	var currentAnimation: SecurityAnimation = .domesticAnimation

	/// Setup all the views
	override func setupViews() {

		super.setupViews()

		backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(backgroundImageView)
		addSubview(animationView)
		addSubview(primaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		backgroundImageView.embed(in: self)
		animationView.embed(in: self, insets: UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0))
		primaryButton.embed(in: self)
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		animatingLeftToRight.toggle()

		if animatingLeftToRight {
			animationView.transform = CGAffineTransform(scaleX: 1, y: 1)
		} else {
			animationView.transform = CGAffineTransform(scaleX: -1, y: 1)
		}
	}

	/// Play the animation
	private func playCurrentAnimation() {

		animationView.animation = currentAnimation.animation
		animationView.loopMode = currentAnimation.loopMode
		animationView.play()
	}

	// MARK: Public Access

	/// Play the animation
	func play() {

		playCurrentAnimation()
	}

	/// Resume the animation
	func resume() {

		if !animationView.isAnimationPlaying {
			logVerbose("Animation resuming")
			playCurrentAnimation()
		} else {
			logVerbose("Animation is playing!")
		}
	}

	func setupForInternational() {

		currentAnimation = .internationalAnimation
		backgroundImageView.isHidden = true
	}
}

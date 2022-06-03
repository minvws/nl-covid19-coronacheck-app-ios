/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Lottie

class SecurityFeaturesView: BaseView {

	private var animatingLeftToRight = true

	/// The animation view
	private let animationView: AnimationView = {

		let view = AnimationView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundBehavior = .pauseAndRestore
		view.respectAnimationFrameRate = true
		return view
	}()

	/// The current animation
	var currentAnimation: SecurityAnimation = .domesticAnimation

	/// Setup all the views
	override func setupViews() {

		super.setupViews()

		backgroundColor = C.white()
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapFlipAnimation))
		addGestureRecognizer(tapGesture)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(animationView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		animationView.embed(in: self)
	}

	/// User tapped to flip security view animation
	@objc func tapFlipAnimation() {

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

		if let section = currentAnimation.section {
			// only play a section of the animation
			animationView.play(
				fromFrame: section.start,
				toFrame: section.end,
				loopMode: currentAnimation.loopMode,
				completion: nil
			)
		} else {
			animationView.play()
		}
	}

	// MARK: Public Access

	/// Play the animation
	func play() {

		playCurrentAnimation()
	}

	/// Resume the animation
	func resume() {

		if !animationView.isAnimationPlaying {
			playCurrentAnimation()
		}
	}

	func setupForInternational() {

		currentAnimation = .internationalAnimation
	}
}

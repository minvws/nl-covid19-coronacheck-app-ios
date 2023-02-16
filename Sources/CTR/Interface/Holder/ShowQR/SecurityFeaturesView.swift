/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Lottie
import Shared
import ReusableViews
import Resources

class SecurityFeaturesView: BaseView {

	private var animatingLeftToRight = true

	/// The animation view
	private let animationView: LottieAnimationView = {

		let view = LottieAnimationView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundBehavior = .pauseAndRestore
		view.respectAnimationFrameRate = true
		return view
	}()

	/// The current animation
	var currentAnimation: SecurityAnimation = .domesticSummerAnimation {
		didSet {
			updateAccessibility()
		}
	}

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

	override func setupAccessibility() {
		super.setupAccessibility()
		isAccessibilityElement = true
		accessibilityTraits = [.button]
		
		updateAccessibility()
	}
	
	private func updateAccessibility() {
		accessibilityLabel = currentAnimation.localizedLabel
		accessibilityHint = currentAnimation.localizedHint
	}
	
	/// User tapped to flip security view animation
	@objc func tapFlipAnimation() {

		animatingLeftToRight.toggle()

		if animatingLeftToRight {
			animationView.transform = CGAffineTransform(scaleX: 1, y: 1)
		} else {
			animationView.transform = CGAffineTransform(scaleX: -1, y: 1)
		}
		
		updateAccessibility()
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
			playCurrentAnimation()
		}
	}
}

private extension SecurityAnimation {
	
	var localizedLabel: String? {
		switch self {
			case .domesticSummerAnimation: return L.holder_showqr_animation_summerctb_voiceover_label()
			case .domesticWinterAnimation: return L.holder_showqr_animation_winterctb_voiceover_label()
			case .internationalSummerAnimation: return L.holder_showqr_animation_summerdcc_voiceover_label()
			case .internationalWinterAnimation: return L.holder_showqr_animation_winterdcc_voiceover_label()
			default: return nil
		}
	}
	
	var localizedHint: String? {
		return L.holder_showqr_animation_voiceover_hint()
	}
}

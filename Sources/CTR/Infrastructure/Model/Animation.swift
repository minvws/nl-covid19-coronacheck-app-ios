/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Lottie

/// Protocol to extend Lottie Animations with a name to identify while debugging
protocol NamedAnimationProtocol {

	/// The name of this animation
	var name: String { get }

	/// The loop mode for this animation (playOnce, loop, repeat, autoReverse)
	var loopMode: LottieLoopMode { get }

	/// The Lottie Animation
	var animation: Animation? { get set }

	/// The playable part to the animation. If nil, the whole animation is played.
	var section: (start: AnimationProgressTime, end: AnimationProgressTime)? { get set }
}

struct SecurityAnimation: NamedAnimationProtocol, Equatable {

	/// The name of this animation
	var name: String

	/// The loop mode for this animation (playOnce, loop, repeat, autoReverse)
	var loopMode: LottieLoopMode = .loop

	/// The Lottie Animation
	var animation: Animation?

	/// The playable part to the animation. If nil, the whole animation is played.
	var section: (start: AnimationFrameTime, end: AnimationFrameTime)?

	/// Initializer
	/// - Parameters:
	///   - name: the name of the animation
	///   - fileName: the name of the file
	init(name: String, fileName: String, section: (start: AnimationFrameTime, end: AnimationFrameTime)? = nil) {

		self.name = name
		self.animation = Animation.named(fileName)
		self.section = section
	}

	/// Equality
	/// - Parameters:
	///   - lhs: SecurityAnimation
	///   - rhs: SecurityAnimation
	/// - Returns: True if equal (names match)
	static func == (lhs: SecurityAnimation, rhs: SecurityAnimation) -> Bool {

		return lhs.name == rhs.name
	}
}

extension SecurityAnimation {

	static let domesticAnimation = SecurityAnimation(
		name: "domesticAnimation",
		fileName: "skatefiets-2"
	)

	static let internationalAnimation = SecurityAnimation(
		name: "internationalAnimation",
		fileName: "lf20_fnpdb2ex"
	)
}

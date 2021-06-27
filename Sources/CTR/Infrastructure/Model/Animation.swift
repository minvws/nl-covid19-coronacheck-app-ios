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
}

struct SecurityAnimation: NamedAnimationProtocol, Equatable {

	/// The name of this animation
	var name: String

	/// The loop mode for this animation (playOnce, loop, repeat, autoReverse)
	var loopMode: LottieLoopMode = .loop

	/// The Lottie Animation
	var animation: Animation?

	/// Initializer
	/// - Parameters:
	///   - name: the name of the animation
	///   - fileName: the name of the file
	init(name: String, fileName: String) {

		self.name = name
		self.animation = Animation.named(fileName)
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

	/// A security animation
	static let cyclistLeftToRight = SecurityAnimation(name: "CyclistLeftToRight", fileName: "fietser_LR_335x256")

	/// A security animation
	static let cyclistRightToLeft = SecurityAnimation(name: "CyclistRightToLeft", fileName: "fietser_RL_335x256")

	///
	static let internationalLeftToRight = SecurityAnimation(name: "CyclistRightToLeft", fileName: "lf20_fnpdb2ex")
}

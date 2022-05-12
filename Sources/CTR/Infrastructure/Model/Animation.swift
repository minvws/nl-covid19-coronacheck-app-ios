/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

	static var domesticAnimation: SecurityAnimation {
		return isWithinWinterPeriod ? .domesticWinterAnimation : .domesticSummerAnimation
	}

	static var internationalAnimation: SecurityAnimation {
		return isWithinWinterPeriod ? .internationalWinterAnimation : .internationalSummerAnimation
	}
	
	/// Show default animation from 21 March - 20 December
	/// Show winter animation from 21 December - 20 March
	static var isWithinWinterPeriod: Bool {
		let calendar = Calendar.autoupdatingCurrent
		let components = calendar.dateComponents([.day, .month], from: Current.now())

		switch (components.month, components.day) {
			case ((1...2)?, _), // all of Jan & Feb
				 (3, (0...20)?), // <= March 20th
				 (12, (21...31)?): // >= December 21
				return true
			default:
				return false
		}
	}

	private static let internationalSummerAnimation = SecurityAnimation(
		name: "internationalSummerAnimation",
		fileName: "international_summer_animation"
	)
	
	private static let domesticSummerAnimation = SecurityAnimation(
		name: "domesticSummerAnimation",
		fileName: "domestic_summer_animation"
	)
 
	private static let internationalWinterAnimation = SecurityAnimation(
		name: "internationalWinterAnimation",
		fileName: "international_winter_animation"
	)

	private static let domesticWinterAnimation = SecurityAnimation(
		name: "domesticWinterAnimation",
		fileName: "domestic_winter_animation"
	)
}

/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Lottie
import Shared

struct SecurityAnimation: Equatable {

	/// The name of this animation
	var name: String

	/// The loop mode for this animation (playOnce, loop, repeat, autoReverse)
	var loopMode: LottieLoopMode = .loop

	/// The Lottie Animation
	var animation: LottieAnimation?

	/// Initializer
	/// - Parameters:
	///   - name: the name of the animation
	///   - fileName: the name of the file
	init(name: String, fileName: String) {

		self.name = name
		self.animation = LottieAnimation.named("Animations/" + fileName, bundle: Shared.R.bundle)
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

	static let internationalSummerAnimation = SecurityAnimation(
		name: "internationalSummerAnimation",
		fileName: "international_summer_animation"
	)
	
	static let domesticSummerAnimation = SecurityAnimation(
		name: "domesticSummerAnimation",
		fileName: "domestic_summer_animation"
	)
 
	static let internationalWinterAnimation = SecurityAnimation(
		name: "internationalWinterAnimation",
		fileName: "international_winter_animation"
	)

	static let domesticWinterAnimation = SecurityAnimation(
		name: "domesticWinterAnimation",
		fileName: "domestic_winter_animation"
	)
}

/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared

// MARK: - Private types
final public class ScreenBrightnessManager {
	
	private let initialBrightness: CGFloat
	private var latestAnimation: UUID?
	
	public init(initialBrightness: CGFloat = UIScreen.main.brightness, notificationCenter: NotificationCenterProtocol) {
		self.initialBrightness = initialBrightness
		
		notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
			self?.animateToFullBrightness()
		}
		notificationCenter.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
			guard let self else { return }
			self.revertToInitialBrightness()
		}
	}
	
	func revertToInitialBrightness() {
		// Extracted from the closure, due to Swift 5.7, where the addObserver closure is Sendable:
		// Main actor-isolated class property 'main' can not be mutated from a Sendable closure
		// Main actor-isolated property 'brightness' can not be mutated from a Sendable closure
		
		// Immediately back to initial brightness as we left the app:
		UIScreen.main.brightness = self.initialBrightness
	}
	
	public func animateToFullBrightness() {
		
		let brightnessStep: CGFloat = 0.03
		var iterationsPermitted = 1 / brightnessStep // a basic guard against fighting with another (unknown, external) brightness loop to change brightness (preventing infinite loop)
		let animationID = UUID()
		latestAnimation = animationID // if we're no longer the latest animation, abort the loop.
		Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
			guard iterationsPermitted > 0,
				  self.latestAnimation == animationID,
				  UIScreen.main.brightness < 1
			else { timer.invalidate(); return }
			
			iterationsPermitted -= 1
			UIScreen.main.brightness += brightnessStep
		}
	}
	
	public func animateToInitialBrightness() {
		guard (0...1).contains(initialBrightness) else {
			UIScreen.main.brightness = 1
			return
		}
		
		let brightnessStep: CGFloat = 0.03
		var iterationsPermitted = 1 / brightnessStep // a basic guard against fighting with another (unknown, external) brightness loop to change brightness (preventing infinite loop)
		let animationID = UUID()
		latestAnimation = animationID // if we're no longer the latest animation, abort the loop.
		Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
			guard iterationsPermitted > 0,
				  self.latestAnimation == animationID,
				  self.initialBrightness < UIScreen.main.brightness,
				  UIScreen.main.brightness > brightnessStep
			else { timer.invalidate(); return }
			
			iterationsPermitted -= 1
			UIScreen.main.brightness -= brightnessStep
		}
	}
}

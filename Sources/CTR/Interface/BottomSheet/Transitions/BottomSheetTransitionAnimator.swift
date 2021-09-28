/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class BottomSheetTransitionAnimator: NSObject {
	
	enum Direction {
		case present
		case dismiss
	}
	
	let interactiveTransition: BottomSheetInteractiveTransition?

	private let direction: Direction
	
	init(direction: Direction, interactiveTransition: BottomSheetInteractiveTransition?) {
		self.direction = direction
		self.interactiveTransition = interactiveTransition
		super.init()
	}
}

extension BottomSheetTransitionAnimator: UIViewControllerAnimatedTransitioning {
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.2
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		switch direction {
			case .present: animatePresentTransition(using: transitionContext)
			case .dismiss: animateDismissTransition(using: transitionContext)
		}
	}
}

private extension BottomSheetTransitionAnimator {
	
	func animatePresentTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let appearingController = transitionContext.viewController(forKey: .to) else { return }
		guard let appearingView = transitionContext.view(forKey: .to) else { return }
		
		let curve = animationCurve(using: transitionContext)
		let duration = transitionDuration(using: transitionContext)
		
		let container = transitionContext.containerView
		container.addSubview(appearingView)
		
		var finalFrame = transitionContext.finalFrame(for: appearingController)
		finalFrame.origin.y = container.frame.height
		appearingView.frame = finalFrame
		
		finalFrame.origin.y -= appearingView.bounds.height
		
		UIView.animate(withDuration: duration, delay: 0, options: [curve, .allowUserInteraction]) {
			appearingView.frame = finalFrame
		} completion: { finished in
			transitionContext.completeTransition(finished)
		}
	}
	
	func animateDismissTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let disappearingController = transitionContext.viewController(forKey: .from) else { return }
		guard let disappearingView = transitionContext.view(forKey: .from) else { return }
		
		let curve = animationCurve(using: transitionContext)
		let duration = transitionDuration(using: transitionContext)
		
		var finalFrame = transitionContext.finalFrame(for: disappearingController)
		disappearingView.frame = finalFrame
		
		finalFrame.origin.y = transitionContext.containerView.frame.height
		
		UIView.animate(withDuration: duration, delay: 0, options: curve) {
			disappearingView.frame = finalFrame
		} completion: { _ in
			if !transitionContext.transitionWasCancelled {
				disappearingView.removeFromSuperview()
			}
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}
	}
	
	func animationCurve(using transitionContext: UIViewControllerContextTransitioning) -> UIView.AnimationOptions {
		return transitionContext.isInteractive ? .curveLinear : .curveEaseOut
	}
}

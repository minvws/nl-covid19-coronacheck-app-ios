/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class BottomSheetInteractiveTransition: UIPercentDrivenInteractiveTransition {
	
	/// A check for UIViewControllerTransitioningDelegate
	var isInteractionInProgress = false
	
	private weak var presentingViewController: UIViewController?
	private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
		let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
		panGestureRecognizer.delegate = self
		return panGestureRecognizer
	}()
	private var translationStart: CGFloat = 0
	
	init(presentingViewController: UIViewController) {
		self.presentingViewController = presentingViewController
		super.init()
		presentingViewController.view.addGestureRecognizer(panGestureRecognizer)
	}
}

private extension BottomSheetInteractiveTransition {
	
	@objc
	func pan(_ gestureRecognizer: UIPanGestureRecognizer) {
		guard let presentingViewController = presentingViewController else { return }
		let recognizerView = gestureRecognizer.view?.superview
		let translation = gestureRecognizer.translation(in: recognizerView)
		var transitionPercentage = translation.y / presentingViewController.view.bounds.height
		transitionPercentage = clamp(transitionPercentage)
		
		let velocity = gestureRecognizer.velocity(in: recognizerView)
		let highVelocity: CGFloat = 300
		let delta: CGFloat = 75
		
		switch gestureRecognizer.state {
			case UIGestureRecognizer.State.began:
				isInteractionInProgress = true
				translationStart = translation.y
				presentingViewController.dismiss(animated: true)
			case UIGestureRecognizer.State.changed:
				update(transitionPercentage)
			case UIGestureRecognizer.State.ended, UIGestureRecognizer.State.cancelled:
				isInteractionInProgress = false
				if velocity.x < highVelocity {
					// Taper off completion speed for smoother transition finish
					completionSpeed = 0.4 * sin(transitionPercentage + 2)
				}
				if translation.y - translationStart > delta, gestureRecognizer.state != .cancelled {
					finish()
				} else {
					cancel()
				}
			default:
				cancel()
		}
	}
	
	func clamp(_ transitionPercentage: CGFloat) -> CGFloat {
		return min(max(transitionPercentage, 0.0), 1.0)
	}
}

extension BottomSheetInteractiveTransition: UIGestureRecognizerDelegate {
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		// First check if scrollView is present, if not, allow pan gesture recognizer
		guard let scrollView = (presentingViewController as? BottomSheetScrollable)?.scrollView else { return true }
		guard panGestureRecognizer == gestureRecognizer else { return false }
		
		let recognizerView = panGestureRecognizer.view?.superview
		let convertedScrollViewRect = scrollView.convert(scrollView.bounds, to: recognizerView)
		
		guard panGestureRecognizer.location(in: recognizerView).y > convertedScrollViewRect.origin.y else { return true }
		
		if scrollView.contentOffset.y == 0, panGestureRecognizer.velocity(in: recognizerView).y > 0 {
			scrollView.cancelScrolling()
			return true
		}
		return false
	}
}

private extension UIScrollView {
	
	func cancelScrolling() {
		guard isScrollEnabled else { return }
		isScrollEnabled = false
		isScrollEnabled = true
	}
}

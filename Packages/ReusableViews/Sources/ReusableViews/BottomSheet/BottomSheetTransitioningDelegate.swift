/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final public class BottomSheetTransitioningDelegate: NSObject {
	
	/// Returns an instance of the delegate. It is retained for the duration of the presentation
	static public var `default`: BottomSheetTransitioningDelegate = {
		return BottomSheetTransitioningDelegate()
	}()
}

extension BottomSheetTransitioningDelegate: UIViewControllerTransitioningDelegate {
	
	public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
	}
	
	public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return BottomSheetTransitionAnimator(direction: .present, interactiveTransition: nil)
	}

	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		guard let bottomSheetModalViewController = dismissed as? BottomSheetModalViewController else { return nil }
		return BottomSheetTransitionAnimator(direction: .dismiss, interactiveTransition: bottomSheetModalViewController.interactiveTransition)
	}

	public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		guard let animator = animator as? BottomSheetTransitionAnimator,
			  let interactiveTransition = animator.interactiveTransition,
			  interactiveTransition.isInteractionInProgress
		else { return nil }
		return interactiveTransition
	}
}

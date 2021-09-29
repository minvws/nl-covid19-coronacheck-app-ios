/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class BottomSheetPresentationController: UIPresentationController {
	
	private lazy var overlayView: UIView = {
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		let overlayView = UIView()
		overlayView.addGestureRecognizer(recognizer)
		overlayView.backgroundColor = UIColor(white: 0, alpha: 0.4)
		overlayView.alpha = 0
		return overlayView
	}()
	
	override var shouldPresentInFullscreen: Bool {
		return false
	}
	
	override func presentationTransitionWillBegin() {
		guard let coordinator = presentedViewController.transitionCoordinator else {
			self.overlayView.alpha = 1
			return
		}
		
		setupOverlay()
		
		coordinator.animate { _ in
			self.overlayView.alpha = 1
		}
	}
	
	override func dismissalTransitionWillBegin() {
		guard let coordinator = presentedViewController.transitionCoordinator else {
			self.overlayView.alpha = 0
			return
		}
		
		coordinator.animate { _ in
			self.overlayView.alpha = 0
		}
	}
	
	override func dismissalTransitionDidEnd(_ completed: Bool) {
		guard completed else { return }
		overlayView.removeFromSuperview()
	}
	
	override var frameOfPresentedViewInContainerView: CGRect {
		let size = presentedViewController.preferredContentSize
		let height = size.height
		let yPoint = containerView!.bounds.height - height
		return CGRect(x: 0, y: yPoint, width: size.width, height: height)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		coordinator.animate { [weak self] _ in
			guard let self = self else { return }
			guard let bottomSheetModalViewController = self.presentedViewController as? BottomSheetModalViewController else { return }
			bottomSheetModalViewController.calculatePreferredContentSize(frame: self.containerView?.frame ?? .zero)
			self.presentedView?.frame = self.frameOfPresentedViewInContainerView
		}
	}
}

private extension BottomSheetPresentationController {
	
	@objc
	func handleTap(_ recognizer: UITapGestureRecognizer) {
		presentingViewController.dismiss(animated: true)
	}
	
	func setupOverlay() {
		guard let containerView = containerView else { return }
		
		containerView.insertSubview(overlayView, at: 0)
		overlayView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			overlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
			overlayView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
			overlayView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
			overlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])
	}
}

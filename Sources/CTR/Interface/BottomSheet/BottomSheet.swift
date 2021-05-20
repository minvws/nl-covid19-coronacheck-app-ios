//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/*
Will present the modal in a "bottom card"-style interface that can be swiped down.

Use like so:

```
modalViewController.transitioningDelegate = cardPresenting
modalViewController.modalPresentationStyle = .custom
modalViewController.modalTransitionStyle = .coverVertical

present(modalViewController, animated: true, completion: nil)
```
*/

final class BottomSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		return BottomSheetPresenter(presentedViewController: presented, presenting: presenting)
	}
}

private final class RoundedCornerWithShadowsView: UIView {
	var shadowLayer: CAShapeLayer!

	override func layoutSubviews() {
		super.layoutSubviews()
		self.clipsToBounds = false

		if shadowLayer == nil {
			shadowLayer = CAShapeLayer()
			layer.insertSublayer(shadowLayer, at: 0)
		}

		let cornerRadius: CGFloat = 10
		shadowLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
		shadowLayer.fillColor = UIColor.white.cgColor

		shadowLayer.shadowColor = UIColor.black.cgColor
		shadowLayer.shadowPath = shadowLayer.path
		shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
		shadowLayer.shadowOpacity = 0.3
		shadowLayer.shadowRadius = 40
	}
}

private final class CloseButtonRowView: UIView {

	private let button: UIButton

	init() {
		button = UIButton(type: .custom)
		button.setImage(.cross, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.accessibilityIdentifier = "CloseButton"
		button.accessibilityLabel =  .close
		button.tintColor = Theme.colors.dark

		super.init(frame: CGRect.zero)

		addSubview(button)
		addConstraints([
			button.centerYAnchor.constraint(equalTo: centerYAnchor),
			button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
		])

		button.addTarget(self, action: #selector(CloseButtonRowView.didTapButton), for: .touchUpInside)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var onTapAction: (() -> Void)?

	@objc func didTapButton() {
		onTapAction?()
	}
}

private final class BottomSheetPresenter: UIPresentationController, UIGestureRecognizerDelegate {

	private let dimmingView = UIView()
	private let cardWrapperView = RoundedCornerWithShadowsView()
	private let scrollView = UIScrollView()
	private let topCloseButtonRow = CloseButtonRowView()

	private let panGestureRecognizer = UIPanGestureRecognizer()

	private var cardWrapperViewBottomConstraint: NSLayoutConstraint?
	private var cardWrapperViewTopConstraint: NSLayoutConstraint?

	private let heightOfButtonRow: CGFloat = 60
	// MARK: -

	override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
		super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

		dimmingView.translatesAutoresizingMaskIntoConstraints = false
		dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.5)
		dimmingView.accessibilityIdentifier = "dimmingView"

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapShroud))
		dimmingView.addGestureRecognizer(tapGesture)

		cardWrapperView.translatesAutoresizingMaskIntoConstraints = false
		cardWrapperView.backgroundColor = .clear
		cardWrapperView.accessibilityIdentifier = "cardWrapperView"

		scrollView.backgroundColor = .clear
		scrollView.clipsToBounds = true
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.accessibilityIdentifier = "scrollView"
		scrollView.bounces = false

		topCloseButtonRow.backgroundColor = .clear
		topCloseButtonRow.translatesAutoresizingMaskIntoConstraints = false
		topCloseButtonRow.clipsToBounds = false
		topCloseButtonRow.accessibilityIdentifier = "topCloseButtonRow"
		topCloseButtonRow.onTapAction = { [weak self] in
			self?.dismiss()
		}

		panGestureRecognizer.delegate = self
		panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
		cardWrapperView.addGestureRecognizer(panGestureRecognizer)
	}

	override var presentedView: UIView? {
		return cardWrapperView
	}

	override func presentationTransitionWillBegin() {
		super.presentationTransitionWillBegin()

		installCustomViews()
		installPresentedViewInCustomViews()
		animateDimmingViewIn()
	}

	override func presentationTransitionDidEnd(_ completed: Bool) {
		// Remove views if transition was aborted.
		//
		// If transition completed normally, nothing to do.
		if !completed {
			removeCustomViews()
		}
	}

	override func dismissalTransitionWillBegin() {
		super.dismissalTransitionWillBegin()

		animateDimmingViewOut()
	}

	override func dismissalTransitionDidEnd(_ completed: Bool) {
		// Remove views if transition completed.
		//
		// If transition was aborted, nothing to do.
		if completed {
			removeCustomViews()
		}
	}

	// MARK: - UIPanGestureRecogniser

	private var latestDirection: CGFloat = 0

	@objc func onPan(pan: UIPanGestureRecognizer) {
		let endPoint = pan.translation(in: pan.view?.superview)

		switch pan.state {
			case .began:
				if let topOfReadableContentGuide = containerView?.readableContentGuide.layoutFrame.origin.y,
				   cardWrapperView.frame.origin.y == topOfReadableContentGuide {
					cardWrapperViewTopConstraint?.isActive = true
				}

			case .changed:
				cardWrapperViewBottomConstraint?.constant = endPoint.y
				cardWrapperViewTopConstraint?.constant = endPoint.y

				let velocity = pan.velocity(in: pan.view?.superview)
				latestDirection = velocity.y

			case .ended:
				let moved: CGFloat = {
					if cardWrapperViewTopConstraint?.isActive ?? false {
						return cardWrapperViewTopConstraint!.constant
					} else {
						return cardWrapperViewBottomConstraint!.constant
					}
				}()

				let inertiaToOvercome: CGFloat = 30 // user must move 30pt otherwise it'll just reset back

				if latestDirection > 0 && scrollView.contentOffset.y == 0 && moved > inertiaToOvercome {
					dismiss()
				} else {
					scrollView.isScrollEnabled = true

					cardWrapperViewTopConstraint?.isActive = false
					cardWrapperViewBottomConstraint?.constant = 0
					cardWrapperViewTopConstraint?.constant = 0
					UIView.animate(withDuration: 0.3) {
						self.containerView?.layoutIfNeeded()
					}
				}

			default:
				break
		}
	}

	// MARK: - UIGestureRecognizerDelegate

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }

		let direction = gesture.velocity(in: containerView).y

		scrollView.isScrollEnabled = !(direction > 0 && scrollView.contentOffset.y == 0)

		return false
	}

	// MARK: -

	@objc private func onTapShroud(_ sender: UIControl) {
		dismiss()
	}

	private func dismiss() {
		presentingViewController.dismiss(animated: true, completion: nil)
	}

	private func installCustomViews() {
		guard let containerView = containerView else {
			assertionFailure("Can't set up custom views without a container view. Transition must not be started yet.")
			return
		}

		containerView.addSubview(dimmingView)
		NSLayoutConstraint.activate([
			// Block the content.
			dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
			dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
		])

		containerView.addSubview(cardWrapperView)
		NSLayoutConstraint.activate([
			// Fit the card to the bottom of the screen within the readable width.
			cardWrapperView.topAnchor.constraint(greaterThanOrEqualTo: containerView.readableContentGuide.topAnchor),
			cardWrapperView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			cardWrapperView.bottomAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: 0),
			cardWrapperView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			{
				// Weakly squeeze the content toward the bottom. This functions
				// just like the `verticalFittingPriority` in
				// `UIView.systemLayoutSizeFitting` to get the card to try
				// and fit its content while meeting the other constrainnts.
				let minimizingHeight = cardWrapperView.heightAnchor.constraint(equalToConstant: 0)
				minimizingHeight.priority = .fittingSizeLevel
				return minimizingHeight
			}()
		])

		cardWrapperViewTopConstraint = cardWrapperView.topAnchor.constraint(equalTo: containerView.readableContentGuide.topAnchor)
		cardWrapperViewTopConstraint?.priority = .dragThatCannotResizeScene
		cardWrapperViewTopConstraint?.isActive = false

		cardWrapperViewBottomConstraint = cardWrapperView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		cardWrapperViewBottomConstraint?.priority = .dragThatCannotResizeScene
		cardWrapperViewBottomConstraint?.isActive = true

		cardWrapperView.addSubview(topCloseButtonRow)
		NSLayoutConstraint.activate([
			topCloseButtonRow.leadingAnchor.constraint(equalTo: cardWrapperView.leadingAnchor),
			topCloseButtonRow.trailingAnchor.constraint(equalTo: cardWrapperView.trailingAnchor),
			topCloseButtonRow.topAnchor.constraint(equalTo: cardWrapperView.topAnchor),
			topCloseButtonRow.heightAnchor.constraint(equalToConstant: heightOfButtonRow)
		])

		cardWrapperView.addSubview(scrollView)
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: cardWrapperView.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: cardWrapperView.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: topCloseButtonRow.bottomAnchor),
			scrollView.bottomAnchor.constraint(equalTo: cardWrapperView.bottomAnchor)
		])
	}

	private func installPresentedViewInCustomViews() {
		guard !presentedViewController.view.isDescendant(of: cardWrapperView) else { return }

		presentedViewController.view.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(presentedViewController.view)

		NSLayoutConstraint.activate([
			scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: presentedViewController.view.topAnchor),
			scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: presentedViewController.view.leadingAnchor),
			scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: presentedViewController.view.trailingAnchor),
			scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: presentedViewController.view.bottomAnchor),
			scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: presentedViewController.view.widthAnchor),
			{
				let height = cardWrapperView.heightAnchor.constraint(equalTo: presentedViewController.view.heightAnchor, constant: heightOfButtonRow)
				height.priority = .defaultLow
				return height
			}()
		])
	}

	private func animateDimmingViewIn() {
		dimmingView.alpha = 0
		presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
			self.dimmingView.alpha = 1
		}, completion: nil)
	}

	private func animateDimmingViewOut() {
		presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
			self.dimmingView.alpha = 0
			self.cardWrapperView.shadowLayer.opacity = 0
		}, completion: nil)
	}

	private func removeCustomViews() {
		cardWrapperView.removeFromSuperview()
		dimmingView.removeFromSuperview()
	}
}

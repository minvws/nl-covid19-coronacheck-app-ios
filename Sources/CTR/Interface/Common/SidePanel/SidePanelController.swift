/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

open class SidePanelController: UIViewController, UIGestureRecognizerDelegate {

    /// The current VC displayed in the main pane
	open var selectedViewController: UIViewController? {
		didSet {
			guard oldValue != self.selectedViewController else {
				hideSidePanel()
				return
			}
			oldValue?.view.removeFromSuperview()
			oldValue?.willMove(toParent: nil)
			oldValue?.removeFromParent()
			updateSelectedViewController()

			setNeedsStatusBarAppearanceUpdate()
		}
	}

    /// The hamburger menu:
	let sideController: UIViewController

    /// The width of the panel as a fraction of the screen:
    open var sidePanelFractionalWidthForRegularSizeClass: CGFloat = 0.75
    open var sidePanelFractionalWidthForCompactSizeClass: CGFloat = 0.4

    /// The open and close animation speed, 0.3 seconds
    var animationSpeed: Double = 0.3

	internal weak var sidePanelView: UIView! // hosts the sideController's view
	fileprivate weak var mainView: UIView? // hosts the selectedViewController's view
	fileprivate weak var overlayMainView: UIView! // obscures the selectedViewController when the menu opens

    var sidePanelClosedConstraints: [NSLayoutConstraint]?
    var sidePanelRegularOpenConstraints: [NSLayoutConstraint]?
    var sidePanelCompactOpenConstraints: [NSLayoutConstraint]?

    /// State
	fileprivate var hasLeftSwipeGestureStarted = false
	fileprivate var shouldHideSidePanelOnPanGestureCompletion = true
    /// Flag to indicate if menu is open or not
    fileprivate var sidePanelIsVisible = false

	open func updateSelectedViewController() {
        setupLeftBarButtonItem()

        if let selectedViewController = selectedViewController, let mainView = mainView {
			hideSidePanel()
			addChild(selectedViewController)
			mainView.addSubview(selectedViewController.view)
			selectedViewController.didMove(toParent: self)
        }
    }

    open func setupLeftBarButtonItem() {
        let mainViewController = (selectedViewController as? UINavigationController)?.topViewController ?? selectedViewController
        if let navItem = mainViewController?.navigationItem,
            navItem.leftBarButtonItem == nil {
            
			let config = UIBarButtonItem.Configuration(target: self,
													   action: #selector(showSidePanel),
													   image: I.hamburger(),
													   accessibilityIdentifier: "OpenMenuButton",
													   accessibilityLabel: L.generalMenuOpen())
			navItem.leftBarButtonItem = .create(config)
		}
    }

	override open func viewDidLoad() {

		super.viewDidLoad()
		updateSelectedViewController()

        // Add and configure sideController as a child VC:
		addChild(sideController)
        sidePanelView.addSubview(sideController.view)
        sideController.view.translatesAutoresizingMaskIntoConstraints = false
        sidePanelView.addConstraints([
            sideController.view.leadingAnchor.constraint(equalTo: sidePanelView.leadingAnchor),
            sideController.view.trailingAnchor.constraint(equalTo: sidePanelView.trailingAnchor),
            sideController.view.topAnchor.constraint(equalTo: sidePanelView.topAnchor),
            sideController.view.bottomAnchor.constraint(equalTo: sidePanelView.bottomAnchor)
        ])
		sideController.didMove(toParent: self)

        setupGestureRecognisers()
	}

	open func gestureRecognizer(
		_ gestureRecognizer: UIGestureRecognizer,
		shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

		if otherGestureRecognizer is UISwipeGestureRecognizer {
			return true
		} else {
			return false
		}
	}

	@objc func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        // check to prevent opening menu with a slide left when the menu is closed
        guard sidePanelIsVisible else {
            return
        }
		guard hasLeftSwipeGestureStarted else {
			return
		}

		let frame = sidePanelView.frame
        let sidePanelWidth = sidePanelView.frame.width
		switch panGestureRecognizer.state {
			case .changed:
				let panTranslation = panGestureRecognizer.translation(in: self.view)
				let speed = panGestureRecognizer.velocity(in: self.view).x
				if panTranslation.x <= 0 && abs(panTranslation.x) < frame.width {
					sidePanelView.frame = CGRect(x: panTranslation.x, y: frame.minY, width: frame.width, height: frame.height)
				}
				shouldHideSidePanelOnPanGestureCompletion = abs(panTranslation.x) > sidePanelWidth / 2 || speed < -75.0
				let alpha = 0.1 * (frame.width + frame.minX) / frame.width
				overlayMainView.alpha = alpha
			case .ended:
				hasLeftSwipeGestureStarted = false
				shouldHideSidePanelOnPanGestureCompletion ? hideSidePanel() : showSidePanel()
			default:
				break
		}
	}

	@objc func hideSidePanel() {
		
		guard sidePanelIsVisible else { return }

		UIView.animate(withDuration: animationSpeed, animations: {
            self.updateSidePanelConstraints(
				isVisible: false,
				verticalSizeClass: self.view.traitCollection.verticalSizeClass,
				superview: self.view
			)
            self.view.layoutIfNeeded()
			self.overlayMainView.alpha = 0
		}, completion: { completed  in
            guard completed else { return }
            self.overlayMainView.isHidden = true
            self.sidePanelIsVisible = false

            self.view.disableAllGestureRecognisers()

            if let mainViewController = (self.selectedViewController as? UINavigationController)?.topViewController ?? self.selectedViewController {
                UIAccessibility.post(
					notification: UIAccessibility.Notification.screenChanged,
					argument: mainViewController
				)
            }
            
            self.sidePanelView.accessibilityViewIsModal = false
			self.sidePanelView.isHidden = true
		})
	}

	@objc func showSidePanel() {

		sidePanelView.isHidden = false
		overlayMainView.alpha = 0
		overlayMainView.isHidden = false
		UIView.animate(withDuration: animationSpeed, animations: {
            self.updateSidePanelConstraints(
				isVisible: true,
				verticalSizeClass: self.view.traitCollection.verticalSizeClass,
				superview: self.view
			)
            self.view.layoutIfNeeded()
			self.overlayMainView.alpha = 0.1
        }, completion: { completed in
            guard completed else { return }
            self.sidePanelIsVisible = true

            self.view.enableAllGestureRecognisers()

            UIAccessibility.post(
				notification: UIAccessibility.Notification.screenChanged,
				argument: self.sideController
			)

            self.sidePanelView.accessibilityViewIsModal = true
        })
	}

	@objc func handleSwipeGesture(_ gestureRecognizer: UISwipeGestureRecognizer) {

		if gestureRecognizer.direction == .left {
			hasLeftSwipeGestureStarted = true
			return
		} else {
			showSidePanel()
		}
	}

	public init(sideController: UIViewController) {

		self.sideController = sideController
		super.init(nibName: nil, bundle: Bundle.main)
	}

    required public init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

	override open func loadView() {

		let view = UIView(frame: UIScreen.main.bounds)
		view.backgroundColor = UIColor.white

		let mainView = UIView(frame: view.bounds)
		mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(mainView)

		let overlayView = UIView(frame: view.bounds)
		overlayView.backgroundColor = UIColor.black
		overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		overlayView.isHidden = true
		view.addSubview(overlayView)

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSidePanel))
		overlayView.addGestureRecognizer(tapGesture)

		let sidePanelView = UIView()
        sidePanelView.translatesAutoresizingMaskIntoConstraints = false
		sidePanelView.isHidden = true // Hide for rotation
		view.addSubview(sidePanelView)

        initializeSwappableSidePanelConstraints(sidePanelView: sidePanelView, superView: view)

        // Set constant constraints:
        view.addConstraints([
            sidePanelView.topAnchor.constraint(equalTo: view.topAnchor),
            sidePanelView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        // Set appropriate swappable constraints:
        updateSidePanelConstraints(
			isVisible: false,
			verticalSizeClass: view.traitCollection.verticalSizeClass,
			superview: view
		)

		self.mainView = mainView
		self.overlayMainView = overlayView
        self.sidePanelView = sidePanelView
		self.view = view
	}

    // MARK: - UITraitEnvironment

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        updateSidePanelConstraints(
			isVisible: sidePanelIsVisible,
			verticalSizeClass: traitCollection.verticalSizeClass,
			superview: view
		)
    }

    // MARK: - Private functions

    private func setupGestureRecognisers() {

        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        leftSwipeGesture.direction = .left
        self.view.addGestureRecognizer(leftSwipeGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        self.view.addGestureRecognizer(panGesture)
    }

    /// See `updateSidePanelConstraints` - here we setup the constraints which can be swapped.
    /// Note: takes `superview` as a parameter to prevent infinite-loop
    /// when calling from `loadView` (when referencing `self.view`).
    private func initializeSwappableSidePanelConstraints(sidePanelView: UIView, superView: UIView) {
        sidePanelClosedConstraints = [
            sidePanelView.rightAnchor.constraint(equalTo: superView.leftAnchor),
            sidePanelView.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: sidePanelFractionalWidthForRegularSizeClass, constant: 1)
        ]

        sidePanelRegularOpenConstraints = [
            sidePanelView.leftAnchor.constraint(equalTo: superView.leftAnchor, constant: 0),
            sidePanelView.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: sidePanelFractionalWidthForRegularSizeClass, constant: 1)
        ]

        sidePanelCompactOpenConstraints = [
            sidePanelView.leftAnchor.constraint(equalTo: superView.leftAnchor, constant: 0),
            sidePanelView.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: sidePanelFractionalWidthForCompactSizeClass, constant: 1)
        ]
    }

    /// Applies one of three sets of constraints to the Side Panel to adopt on one of three layout states:
    /// - is visible, with a regular vertical size class
    /// - is visible, with a compact vertical size class
    /// - is hidden
    ///
    /// Note: takes `superview` as a parameter to prevent infinite-loop
    /// when calling from `loadView` (when referencing `self.view`).
    private func updateSidePanelConstraints(
		isVisible: Bool,
		verticalSizeClass: UIUserInterfaceSizeClass,
		superview: UIView) {

        guard let sidePanelClosedConstraints = sidePanelClosedConstraints,
              let sidePanelRegularOpenConstraints = sidePanelRegularOpenConstraints,
              let sidePanelCompactOpenConstraints = sidePanelCompactOpenConstraints
        else { return }

        superview.removeConstraints(sidePanelClosedConstraints)
        superview.removeConstraints(sidePanelRegularOpenConstraints)
        superview.removeConstraints(sidePanelCompactOpenConstraints)

        switch (isVisible, verticalSizeClass) {
            case (true, .regular): // visible, portrait
                superview.addConstraints(sidePanelRegularOpenConstraints)
            case (true, .compact): // visible, landscape
                superview.addConstraints(sidePanelCompactOpenConstraints)
            default: // hidden, portrait/landscape (or else size class is `.unspecified`)
                superview.addConstraints(sidePanelClosedConstraints)
        }

        superview.setNeedsLayout()
    }
}

private extension UIView {
    func disableAllGestureRecognisers() {

        gestureRecognizers?.forEach({ gestureRecognizer in
            gestureRecognizer.isEnabled = false
        })
    }

    func enableAllGestureRecognisers() {

        gestureRecognizers?.forEach({ gestureRecognizer in
            gestureRecognizer.isEnabled = true
        })
    }
}

/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Inject

/// A generic viewcontroller
/// V: The view to use for the scene, must be a (subclass of) baseview
/// M: The class to use as viewModel
class GenericViewController<V: BaseView, M>: UIViewController, UIGestureRecognizerDelegate {
	
	internal var sceneView: V {
		return _sceneView.instance
	}
	fileprivate let _sceneView: _InjectableViewHost<V>
	
	internal let viewModel: M
	
	/// The initializer of the Generic ViewController
	/// - Parameters:
	///   - sceneView: the class to use as the sceneView. Must derive from BaseView
	///   - viewModel: the class to use as the viewModel
	init(sceneView: @autoclosure @escaping () -> V = { V() }(), viewModel: M) {
		
		self._sceneView = Inject.ViewHost(sceneView())
		self.viewModel = viewModel
		
		super.init(nibName: nil, bundle: nil)
		
		#if DEBUG
		if LaunchArgumentsHandler.shouldInjectView() {
			onInjection { [weak self] instance in
				guard let self = self else { return }
				// **For iterative UI development only **
				// The previous instance of self.sceneView is never released, so on each
				// successive injection (due to strong bindings from the ViewModel) a new
				// sceneView instance will be created, without releasing the old one.
				// Therefore there is an an obvious memory leak during development.
				//
				// Other bugs related to having registered multiple observers can also be expected.
				
				Current.logHandler.logDebug("♻️ ♻️ ♻️ Re-Injected View at \(type(of: self)) ♻️ ♻️ ♻️ ")
				self.viewDidLoad()
			}
		}
		#endif
	}
	
	/// Required initialzer
	/// - Parameter coder: the coder
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: View lifecycle
	override func loadView() {
		
		view = _sceneView
	}
	
	/// Enable/disable navigation back swiping. Default is true.
	var enableSwipeBack: Bool { true }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		
		if #available(iOS 13.0, *) {
			return .darkContent
		} else {
			return super.preferredStatusBarStyle
		}
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .all
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			// Always adopt a light interface style.
			overrideUserInterfaceStyle = .light
		}
		
		// Hide standard back button for customized left / back button.
		navigationItem.hidesBackButton = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		navigationController?.interactivePopGestureRecognizer?.delegate = enableSwipeBack ? self : nil
		navigationController?.interactivePopGestureRecognizer?.isEnabled = enableSwipeBack
	}
	
	// MARK: - Accessibility
	
	// If the user is has VoiceOver enabled, they can
	// draw a "Z" shape with two fingers to trigger a navigation pop.
	// http://ronnqvi.st/adding-accessible-behavior
	@objc override func accessibilityPerformEscape() -> Bool {
		if enableSwipeBack {
			onBack()
			return true
		} else if let leftButtonTarget = navigationItem.leftBarButtonItem?.target,
				  let leftButtonAction = navigationItem.leftBarButtonItem?.action {
			UIApplication.shared.sendAction(leftButtonAction, to: leftButtonTarget, from: nil, for: nil)
			return true
		}
		
		return false
	}
	
	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: The action when the users taps the close button
	///   - tintColor: The button tint color
	func addCloseButton(
		action: Selector,
		tintColor: UIColor = C.black()!) {
			
			let config = UIBarButtonItem.Configuration(
				target: self,
				action: action,
				content: .image(I.cross()),
				tintColor: tintColor,
				accessibilityIdentifier: "CloseButton",
				accessibilityLabel: L.generalClose()
			)
			navigationItem.leftBarButtonItem = .create(config)
		}
	
	/// Add a back button to the navigation bar.
	/// - Parameters:
	///   - customAction: The custom action for back navigation
	func addBackButton(
		customAction: Selector? = nil) {
			
			var action = #selector(onBack)
			if let customAction = customAction {
				action = customAction
			}
			
			let config = UIBarButtonItem.Configuration(
				target: self,
				action: action,
				content: .image(I.backArrow()),
				accessibilityIdentifier: "BackButton",
				accessibilityLabel: L.generalBack()
			)
			navigationItem.leftBarButtonItem = .create(config)
		}
	
	@objc func onBack() {
		navigationController?.popViewController(animated: true)
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

/// A generic viewcontroller,which on iPad automagically applies side insets.
/// V: The view to use for the scene, must be a (subclass of) baseview
/// M: The class to use as viewModel
class TraitWrappedGenericViewController<V: BaseView, M>: GenericViewController<V, M> {
	
	override func loadView() {
		
		view = TraitWrapper(self._sceneView)
	}
}

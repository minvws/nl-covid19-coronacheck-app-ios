/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Inject
import Shared

/// A generic viewcontroller
/// V: The view to use for the scene, must be a (subclass of) baseview
/// M: The class to use as viewModel
class GenericViewController<V: BaseView, M>: UIViewController, UIGestureRecognizerDelegate {

	let viewModel: M
	
	// The outward-facing accessor for `sceneView`.
	// Purpose: syntactic sugar for `_sceneViewInstance()`.
	// Release-mode: returns a constant instance.
	// Debug-mode: returns the latest instance of V (after possible hot-reloads).
	var sceneView: V { _sceneViewInstance() }
	
	// Wraps the mechanism for getting the current sceneView instance
	// Purpose: hides the underlying (_available in `DEBUG` only_) `_InjectableViewHost` type
	//			inside a `() -> V` closure.
	// Release-mode: returns a constant instance.
	// Debug-mode: returns the latest instance of V (after possible hot-reloads).
	fileprivate let _sceneViewInstance: () -> V
	
	// Either the `sceneView`, or a type-erased hot-reload wrapper (`_InjectableViewHost`).
	// Purpose: purely for use in `func loadView()`.
	// Release-mode: is the sceneView.
	// Debug-mode: is the hot-reload `_InjectableViewHost` wrapper, which itself embeds the sceneView.
	private let _rootView: UIView
	
	/// The initializer of the Generic ViewController
	/// - Parameters:
	///   - sceneView: the class to use as the sceneView. Must derive from BaseView
	///   - viewModel: the class to use as the viewModel
	init(sceneView: @autoclosure @escaping () -> V = { V() }(), viewModel: M) {
		
		self.viewModel = viewModel
		
		#if DEBUG
			let host: _InjectableViewHost = Inject.ViewHost(sceneView())
			_rootView = host
			_sceneViewInstance = { host.instance }
		#else
			let sceneViewInstance: V = sceneView()
			_rootView = sceneViewInstance
			_sceneViewInstance = { sceneViewInstance }
		#endif
 
		super.init(nibName: nil, bundle: nil)
		
		#if DEBUG
			if LaunchArgumentsHandler.shouldInjectView() {
				onInjection { [weak self] instance in
					guard let self = self else { return }
					// **For iterative UI development only **
					// The previous instance of self.sceneView is never released (due to
					// strong bindings from the ViewModel), so on each successive injection
					// a new sceneView instance will be created, without releasing the old one.
					// Therefore there is an an obvious memory leak during development.
					//
					// Other bugs related to having registered multiple observers can also be expected.
					
					// The updated `host.instance` value is only available after `onInjection`
					// completes, so need to jump to next runloop:
					DispatchQueue.main.async {
						self.viewDidLoad()
						logDebug("♻️ ♻️ ♻️ Re-Injected View at \(type(of: self)) ♻️ ♻️ ♻️ ")
					}
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
		
		view = _rootView
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
		
		view = TraitWrapper(_sceneViewInstance())
	}
}

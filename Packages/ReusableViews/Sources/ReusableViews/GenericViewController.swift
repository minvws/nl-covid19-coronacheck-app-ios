/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import Resources

/*
 A generic viewcontroller, used to reduce scaffolding
 V: The view to use for the scene, must be a (subclass of) baseview
 M: The class to use as viewModel
 */
open class GenericViewController<V: BaseView, M>: UIViewController, UIGestureRecognizerDelegate {

	public let viewModel: M
	
	public let sceneView: V
	
	/// The initializer of the Generic ViewController
	/// - Parameters:
	///   - sceneView: the class to use as the sceneView. Must derive from BaseView
	///   - viewModel: the class to use as the viewModel
	public init(sceneView: V = V(), viewModel: M) {
		
		self.sceneView = sceneView
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	/// Required initialzer
	/// - Parameter coder: the coder
	@available(*, unavailable)
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: View lifecycle
	override open func loadView() {
		
		view = sceneView
	}
	
	/// Enable/disable navigation back swiping. Default is true.
	open var enableSwipeBack: Bool { true }
	
	override open var preferredStatusBarStyle: UIStatusBarStyle {
		
		if #available(iOS 13.0, *), AppFlavor.flavor == .verifier {
			return .darkContent
		} else {
			return super.preferredStatusBarStyle
		}
	}
	
	override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .all
	}
	
	override open func viewDidLoad() {
		
		super.viewDidLoad()
		
		navigationItem.largeTitleDisplayMode = .never // overriding in subclass is okay.
		
		if #available(iOS 13.0, *), AppFlavor.flavor == .verifier {
			// Always adopt a light interface style.
			overrideUserInterfaceStyle = .light
		}
		
		// Hide standard back button for customized left / back button.
		navigationItem.hidesBackButton = true
	}
	
	override open func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		navigationController?.interactivePopGestureRecognizer?.delegate = enableSwipeBack ? self : nil
		navigationController?.interactivePopGestureRecognizer?.isEnabled = enableSwipeBack
	}
	
	// MARK: - Accessibility
	
	// If the user is has VoiceOver enabled, they can
	// draw a "Z" shape with two fingers to trigger a navigation pop.
	// http://ronnqvi.st/adding-accessible-behavior
	@objc override open func accessibilityPerformEscape() -> Bool {
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
	open func addCloseButton(
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
	
	open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

/// A generic viewcontroller,which on iPad automagically applies side insets.
/// V: The view to use for the scene, must be a (subclass of) baseview
/// M: The class to use as viewModel
open class TraitWrappedGenericViewController<V: BaseView, M>: GenericViewController<V, M> {
	
	override public func loadView() {
		
		view = TraitWrapper(sceneView)
	}
}

extension UIViewController {
	
	public func addBackButton(
		customAction: Selector? = nil) {
			
			var action = #selector(onBack)
			if let customAction {
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
	
	@objc open func onBack() {
		navigationController?.popViewController(animated: true)
	}
}

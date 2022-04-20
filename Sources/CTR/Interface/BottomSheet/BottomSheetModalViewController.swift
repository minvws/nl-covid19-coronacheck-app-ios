/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol BottomSheetScrollable: AnyObject {
	
	/// Used by BottomSheetInteractiveTransition
	var scrollView: UIScrollView { get }
}

final class BottomSheetModalViewController: BaseViewController, BottomSheetScrollable {
	
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 62
			static let closeButton: CGFloat = 22
		}
	}
	
	var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()
	
	private let closeButton: TappableButton = {
		let button = TappableButton()
		button.setImage(I.cross(), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.accessibilityIdentifier = "CloseButton"
		button.accessibilityLabel = L.generalClose()
		button.tintColor = C.black()
		button.setupLargeContentViewer(title: L.generalClose())
		return button
	}()
	
	var interactiveTransition: BottomSheetInteractiveTransition?
	
	internal let childViewController: UIViewController
	
	init(childViewController: UIViewController) {
		self.childViewController = childViewController
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
		calculatePreferredContentSize(frame: view.frame)
		
		interactiveTransition = BottomSheetInteractiveTransition(presentingViewController: self)
	}
	
	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()
		scrollView.contentInset.bottom = view.safeAreaInsets.bottom
	}
    
    override func accessibilityPerformEscape() -> Bool {
        dismissModal()
        return true
    }
	
	/// Set preferredContentSize, used by UIPresentationController
	/// - Parameter frame: The frame used to calculate the size
	func calculatePreferredContentSize(frame: CGRect) {
		let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
		let width = frame.width
		let maxHeight = frame.height - safeAreaInsets.top
		var height = maxHeight
		let additionalHeight = ViewTraits.Margin.top + safeAreaInsets.bottom
		
		resizeScrollView(size: frame.size)
		
		scrollView.layoutIfNeeded()
		let scrollViewHeight = scrollView.contentSize.height + additionalHeight
		scrollView.isScrollEnabled = scrollViewHeight > maxHeight
		height = min(maxHeight, scrollViewHeight)
		
		resizeScrollView(size: .init(width: width, height: height))
		
		preferredContentSize = .init(width: width, height: height)
	}
}

private extension BottomSheetModalViewController {
	
	func setupViews() {
		view.backgroundColor = C.white()
		view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		view.layer.cornerRadius = 10
		view.layer.shadowColor = C.shadow()?.cgColor
		view.layer.shadowOpacity = 0.1
		view.layer.shadowRadius = 10
		view.clipsToBounds = true
		
		closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
	}
	
	func setupViewHierarchy() {
		addChild(childViewController)
		childViewController.didMove(toParent: self)
		view.addSubview(scrollView)
		scrollView.addSubview(childViewController.view)
		view.addSubview(closeButton)
	}
	
	func setupViewConstraints() {
		childViewController.view.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			childViewController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
			childViewController.view.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
			childViewController.view.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
			childViewController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			childViewController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: ViewTraits.Margin.closeButton),
			closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ViewTraits.Margin.closeButton)
		])
	}
	
	@objc
	func dismissModal() {
		dismiss(animated: true)
	}
	
	func resizeScrollView(size: CGSize) {
		// Setting the frame instead of layout constraint will improve rotation animation
		scrollView.frame = .init(origin: .init(x: 0,
											   y: ViewTraits.Margin.top),
								 size: .init(width: size.width,
											 height: size.height - ViewTraits.Margin.top))
	}
}

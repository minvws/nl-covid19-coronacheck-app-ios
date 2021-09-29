/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol BottomSheetScrollable: AnyObject {
	
	var modalScrollView: UIScrollView? { get }
}

final class BottomSheetModalViewController: BaseViewController, BottomSheetScrollable {
	
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 60
			static let closeButton: CGFloat = 22
		}
	}
	
	var modalScrollView: UIScrollView? {
		return scrollView
	}
	
	private let closeButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setImage(I.cross(), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.accessibilityIdentifier = "CloseButton"
		button.accessibilityLabel = L.generalClose()
		button.tintColor = Theme.colors.dark
		return button
	}()
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.bounces = false
		return scrollView
	}()
	
	var interactiveTransition: BottomSheetInteractiveTransition?
	
	private let childViewController: UIViewController
	
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
	
	func calculatePreferredContentSize(frame: CGRect) {
		let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
		let maxHeight = frame.height - safeAreaInsets.top
		var height = maxHeight
		let additionalHeight = ViewTraits.Margin.top + safeAreaInsets.bottom
		
		scrollView.layoutIfNeeded()
		let scrollViewHeight = scrollView.contentSize.height + additionalHeight
		scrollView.isScrollEnabled = scrollViewHeight > maxHeight
		height = min(maxHeight, scrollViewHeight)
		
		resizeScrollView(frame: frame)
		
		preferredContentSize = .init(width: frame.width, height: height)
	}
}

private extension BottomSheetModalViewController {
	
	func setupViews() {
		view.backgroundColor = .white
		view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		view.layer.cornerRadius = 10
		view.layer.shadowColor = UIColor.black.cgColor
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
			childViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
			
			closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: ViewTraits.Margin.closeButton),
			closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ViewTraits.Margin.closeButton)
		])
	}
	
	@objc
	func dismissModal() {
		dismiss(animated: true)
	}
	
	func resizeScrollView(frame: CGRect) {
		scrollView.frame = .init(origin: .init(x: 0,
											   y: ViewTraits.Margin.top),
								 size: .init(width: frame.width,
											 height: frame.height - ViewTraits.Margin.top))
	}
}

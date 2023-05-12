/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Resources

final class HolderDashboardView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Spacing {
			static let stackView: CGFloat = 24
		}
	}
	
	private let fakeNavigationBar: FakeNavigationBarView = {
		let navbar = FakeNavigationBarView()
		navbar.translatesAutoresizingMaskIntoConstraints = false
		return navbar
	}()
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()
	
	/// The scrolled stackview to display international cards
	let internationalScrollView: ScrolledStackView = {
		let scrollView = ScrolledStackView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.stackView.spacing = ViewTraits.Spacing.stackView
		scrollView.backgroundColor = C.white()
		return scrollView
	}()
	
	/// Footer view with primary button
	let footerButtonView: FooterButtonView = {
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()
	
	private var bottomScrollViewConstraint: NSLayoutConstraint?
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	// MARK: - Overrides
	
	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
		scrollView.delegate = self
		footerButtonView.isHidden = true
		
		NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
			DispatchQueue.main.async { // because otherwise `UIApplication.shared.keyWindow?.bounds.width` has the wrong value 🙄
				self?.updateStackViewInsets()
			}
		}
		updateStackViewInsets()
	}
	
	/// Setup the view hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(fakeNavigationBar)
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(internationalScrollView)
	}

	/// Setup all the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
	
		NSLayoutConstraint.activate([
			
			fakeNavigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			fakeNavigationBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			fakeNavigationBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			
			scrollView.topAnchor.constraint(equalTo: fakeNavigationBar.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			{
				let constraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
				bottomScrollViewConstraint = constraint
				return constraint
			}(),
			
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			internationalScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			internationalScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			internationalScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			internationalScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			internationalScrollView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor),
			{
				let constraint = internationalScrollView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
				constraint.priority = .defaultLow
				return constraint
			}()
		])
	}
	
	override var accessibilityElements: [Any]? {
		get {
			return [fakeNavigationBar, internationalScrollView, footerButtonView]
		}
		set {}
	}
	
	/// Enables swipe to navigate behaviour for assistive technologies
	override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
		
		// Scroll via swipe gesture
		return false
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateStackViewInsets()
	}
	
	private func updateStackViewInsets() {
		guard let windowWidth = UIApplication.shared.keyWindow?.bounds.width else { return }
		
		let insets: NSDirectionalEdgeInsets? = {
			guard !(traitCollection.preferredContentSizeCategory.isAccessibilityCategory || traitCollection.horizontalSizeClass == .compact)
			else { return nil }
			
			let contentPercentageWidth: CGFloat = 0.65
			let horizontalInset = CGFloat((windowWidth - windowWidth * contentPercentageWidth) / 2)
			return NSDirectionalEdgeInsets(top: 8, leading: horizontalInset, bottom: 8, trailing: horizontalInset)
		}()
		
		internationalScrollView.stackView.insets(insets)
	}
	
	// MARK: - Public Access
	
	/// Display primary button view
	var shouldDisplayButtonView = false {
		didSet {
			footerButtonView.isHidden = !shouldDisplayButtonView
			bottomScrollViewConstraint?.isActive = false
			let anchor: NSLayoutYAxisAnchor = shouldDisplayButtonView ? footerButtonView.topAnchor : self.bottomAnchor
			bottomScrollViewConstraint = scrollView.bottomAnchor.constraint(equalTo: anchor)
			bottomScrollViewConstraint?.isActive = true
		}
	}
	
	var tapMenuButtonHandler: (() -> Void)? {
		didSet {
			fakeNavigationBar.tapMenuButtonHandler = tapMenuButtonHandler
		}
	}
	
	var fakeNavigationTitle: String? {
		didSet {
			fakeNavigationBar.title = fakeNavigationTitle
		}
	}
	
	var fakeNavigationBarAlpha: CGFloat {
		get {
			fakeNavigationBar.alpha
		}
		set {
			fakeNavigationBar.alpha = newValue
		}
	}
}

private extension HolderDashboardView {
	
	func updateFooterViewAnimation(for scrollView: UIScrollView) {
		let translatedOffset = scrollView.translatedBottomScrollOffset
		footerButtonView.updateFadeAnimation(from: translatedOffset)
	}
}

extension HolderDashboardView: UIScrollViewAccessibilityDelegate {
	
	func accessibilityScrollStatus(for scrollView: UIScrollView) -> String? {
		return L.generalEuropeanUnion()
	}
}

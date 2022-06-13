/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// A wrapper around a fake navigation bar and the content that goes underneath
/// Is _not_ comparible to a UINavigationController, as this class does no navigation.
class FakeNavigationBarContainer<View: BaseView>: BaseView {
	let containedView: View
	
	private let fakeNavigationBar: FakeNavigationBarView = {
		let navbar = FakeNavigationBarView()
		navbar.translatesAutoresizingMaskIntoConstraints = false
		return navbar
	}()
	
	private var backgroundColorObserverToken: NSKeyValueObservation?

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
	
	init(_ containedView: View) {
		self.containedView = containedView
		super.init(frame: .zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("unimplemented.")
	}
	
	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		containedView.translatesAutoresizingMaskIntoConstraints = false
	}

	/// Setup the view hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		addSubview(fakeNavigationBar)
		addSubview(containedView)
		
		setupBackgroundColorObserver()
	}
	
	private func setupBackgroundColorObserver() {
		// Observe the sceneView background color for changes and apply to self:
		backgroundColorObserverToken = containedView.observe(\.observableBackgroundColor, options: [.new]) { [weak self] _, change in
			self?.backgroundColor = change.newValue!
		}
		self.backgroundColor = containedView.backgroundColor
	}
	
	/// Setup all the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			fakeNavigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			fakeNavigationBar.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			fakeNavigationBar.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			
			containedView.topAnchor.constraint(equalTo: fakeNavigationBar.bottomAnchor),
			
			containedView.leadingAnchor.constraint(equalTo: leadingAnchor),
			containedView.trailingAnchor.constraint(equalTo: trailingAnchor),
			containedView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	/// Setup all the accessibility traits
	override func setupAccessibility() {
		super.setupAccessibility()
		
	}
}

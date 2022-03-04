/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TraitWrapper<View: BaseView>: BaseView {
	
	let sceneView: View
	
	private lazy var constrainedWidthConstraint: NSLayoutConstraint = sceneView.widthAnchor.constraint(equalTo: widthAnchor)
	private lazy var regularWidthConstraint: NSLayoutConstraint = {
		NSLayoutConstraint(item: sceneView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.666, constant: 1)
	}()
	
	private var backgroundColorObserverToken: NSKeyValueObservation?

	init(_ sceneView: View) {
		self.sceneView = sceneView
		super.init(frame: .zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("unimplemented.")
	}
	
	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		sceneView.translatesAutoresizingMaskIntoConstraints = false
	}

	/// Setup the view hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		addSubview(sceneView)

		setupBackgroundColorObserver()
	}
	
	/// Setup all the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		addConstraints([
			constrainedWidthConstraint,
			regularWidthConstraint
		])
		
		NSLayoutConstraint.activate([
			sceneView.centerXAnchor.constraint(equalTo: centerXAnchor),
			sceneView.topAnchor.constraint(equalTo: topAnchor),
			sceneView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
		
		activateCorrectConstraint(forTraitCollection: traitCollection)
	}
	
	/// Setup all the accessibility traits
	override func setupAccessibility() {
		super.setupAccessibility()
		
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		activateCorrectConstraint(forTraitCollection: traitCollection)
	}
	
	private func setupBackgroundColorObserver() {
		// Observe the sceneView background color for changes and apply to self:
		backgroundColorObserverToken = sceneView.observe(\.observableBackgroundColor, options: [.new]) { [weak self] _, change in
			self?.backgroundColor = change.newValue!
		}
		self.backgroundColor = sceneView.backgroundColor
	}
	
	private func activateCorrectConstraint(forTraitCollection traitCollection: UITraitCollection) {
		
		switch traitCollection.horizontalSizeClass {
			case .regular:
				constrainedWidthConstraint.isActive = false
				regularWidthConstraint.isActive = true
			default:
				constrainedWidthConstraint.isActive = true
				regularWidthConstraint.isActive = false
		}
		
		setNeedsLayout()
		layoutSubviews()
	}
}

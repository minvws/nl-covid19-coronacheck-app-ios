/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol Embeddable {
	var view: UIView? { get }

	var leadingAnchor: NSLayoutXAxisAnchor { get }
	var trailingAnchor: NSLayoutXAxisAnchor { get }
	var topAnchor: NSLayoutYAxisAnchor { get }
	var bottomAnchor: NSLayoutYAxisAnchor { get }
}

struct CustomEmbeddable: Embeddable {
	let view: UIView?
	let leadingAnchor: NSLayoutXAxisAnchor
	let trailingAnchor: NSLayoutXAxisAnchor
	let topAnchor: NSLayoutYAxisAnchor
	let bottomAnchor: NSLayoutYAxisAnchor
}

extension UIView {

	/// Returns a container with horizontal constraints to the readableContentGuide and vertical constraints to the normal top and bottom anchors.
	var readableWidth: Embeddable {
		return CustomEmbeddable(
			view: self,
			leadingAnchor: readableContentGuide.leadingAnchor,
			trailingAnchor: readableContentGuide.trailingAnchor,
			topAnchor: topAnchor,
			bottomAnchor: bottomAnchor)
	}

	/// Returns a container with horizontal constraints to the leading readableContentGuide
	/// and the trailing anchor and vertical constraints to the normal top and bottom anchors.
	/// An example use is a separator within a `UITableViewCell` that has a left margin, but extends to the right off the screen.
	var readableIdentation: Embeddable {
		return CustomEmbeddable(
			view: self,
			leadingAnchor: readableContentGuide.leadingAnchor,
			trailingAnchor: trailingAnchor,
			topAnchor: topAnchor,
			bottomAnchor: bottomAnchor)
	}

}

extension UIView: Embeddable {
	var view: UIView? {
		return self
	}
}

extension UILayoutGuide: Embeddable {
	var view: UIView? {
		return owningView
	}

}

extension UIView: Logging {

	/// Convenience method for a common layout where a subview is added to a view and needs constraints for all four sides.
	///
	/// - parameter embeddable: The container conforming to Embeddable to which the receiver will be added
	/// - parameter insets: The insets that will be applied to the constraints
	/// - parameter preservesSuperviewLayoutMargins: A Boolean value indicating whether the receiver also respects the margins of its container. Defaults to true
	/// # Example uses:
	/// ````
	/// someView.embed(in: otherView)
	/// someView.embed(in: otherView.safeAreaLayoutGuide)
	/// someView.embed(in: otherView.safeAreaLayoutGuide, insets: .top(50) + .left(10))
	/// someView.embed(in: otherView.readableWidth)
	/// someView.embed(in: otherView.readableContentGuide)
	/// ````
	/// - Tag: Embed
	@discardableResult
	func embed(
		in embeddable: Embeddable,
		insets: UIEdgeInsets = .zero,
		preservesSuperviewLayoutMargins: Bool = true) -> Self {

		guard let view = embeddable.view else {
			logError("Warning: could not embed view(\(self)) to embeddable(\(embeddable))")
			return self
		}

		view.addSubview(self)
		view.preservesSuperviewLayoutMargins = preservesSuperviewLayoutMargins
		self.preservesSuperviewLayoutMargins = preservesSuperviewLayoutMargins

		translatesAutoresizingMaskIntoConstraints = false
		leadingAnchor.constraint(equalTo: embeddable.leadingAnchor, constant: insets.left).isActive = true
		trailingAnchor.constraint(equalTo: embeddable.trailingAnchor, constant: -insets.right).isActive = true
		topAnchor.constraint(equalTo: embeddable.topAnchor, constant: insets.top).isActive = true
		bottomAnchor.constraint(equalTo: embeddable.bottomAnchor, constant: -insets.bottom).isActive = true

		return self
	}

}

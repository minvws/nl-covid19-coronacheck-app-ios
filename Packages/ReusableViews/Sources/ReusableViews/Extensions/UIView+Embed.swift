/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

public protocol Embeddable {
	var view: UIView? { get }

	var leadingAnchor: NSLayoutXAxisAnchor { get }
	var trailingAnchor: NSLayoutXAxisAnchor { get }
	var topAnchor: NSLayoutYAxisAnchor { get }
	var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: Embeddable {
	public var view: UIView? {
		return self
	}
}

extension UILayoutGuide: Embeddable {
	public var view: UIView? {
		return owningView
	}
}

extension UIView {

	/// Convenience method for a common layout where a subview is added to a view and needs constraints for all four sides.
	///
	/// - parameter embeddable: The container conforming to Embeddable to which the receiver will be added
	/// - parameter insets: The insets that will be applied to the constraints
	/// # Example uses:
	/// ````
	/// someView.embed(in: otherView)
	/// someView.embed(in: otherView.safeAreaLayoutGuide)
	/// someView.embed(in: otherView.safeAreaLayoutGuide, insets: .top(50) + .left(10))
	/// ````
	/// - Tag: Embed
	@discardableResult
	public func embed(
		in embeddable: Embeddable,
		insets: UIEdgeInsets = .zero) -> Self {

		guard let view = embeddable.view else {
			logError("Warning: could not embed view(\(self)) to embeddable(\(embeddable))")
			return self
		}

		view.addSubview(self)

		translatesAutoresizingMaskIntoConstraints = false
		leadingAnchor.constraint(equalTo: embeddable.leadingAnchor, constant: insets.left).isActive = true
		trailingAnchor.constraint(equalTo: embeddable.trailingAnchor, constant: -insets.right).isActive = true
		topAnchor.constraint(equalTo: embeddable.topAnchor, constant: insets.top).isActive = true
		bottomAnchor.constraint(equalTo: embeddable.bottomAnchor, constant: -insets.bottom).isActive = true

		return self
	}
}

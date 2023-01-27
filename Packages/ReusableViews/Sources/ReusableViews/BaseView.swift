/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

open class BaseView: UIView {

	override open var backgroundColor: UIColor? {
		didSet {
			guard let backgroundColor = backgroundColor else {
				return
			}

			observableBackgroundColor = backgroundColor
		}
	}
	
	@objc dynamic open var observableBackgroundColor: UIColor = .black
	
	/// Initializer
	/// - Parameter frame: the frame for the view
	override public init(frame: CGRect) {

		// Init

		super.init(frame: frame)

		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
		setupAccessibility()
	}

	/// Required initializer
	/// - Parameter aDecoder: decoder
	required public init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)

		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
		setupAccessibility()
	}

	/// Setup all the views
	open func setupViews() {

		// Base view doesn't need to do any setup
	}

	/// Setup the view hierarchy
	open func setupViewHierarchy() {

		// Base view doesn't need to do any setup
	}

	/// Setup all the constraints
	open func setupViewConstraints() {

		// Base view doesn't need to do any setup
	}

	/// Setup all the accessibility traits
	open func setupAccessibility() {

		// Base view doesn't need to do any setup
	}
}

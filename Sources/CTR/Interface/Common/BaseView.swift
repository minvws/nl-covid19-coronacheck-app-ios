/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class BaseView: UIView {

	/// Initializer
	/// - Parameter frame: the frame for the view
	override init(frame: CGRect) {

		// Init

		super.init(frame: frame)

		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
		setupAccessibility()
	}

	/// Required initializer
	/// - Parameter aDecoder: decoder
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)

		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
		setupAccessibility()
	}

	/// Setup all the views
	func setupViews() {

		// Base view doesn't need to do any setup
	}

	/// Setup the view hierarchy
	func setupViewHierarchy() {

		// Base view doesn't need to do any setup
	}

	/// Setup all the constraints
	func setupViewConstraints() {

		// Base view doesn't need to do any setup
	}

	/// Setup all the accessibility traits
	func setupAccessibility() {

		// Base view doesn't need to do any setup
	}
}

/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Resources

/*
 Scrollview that keeps its content at full height. Can be used with subviews pinned to top and bottom of scrollview.
 */
public final class ScrolledContentHeightView: UIScrollView {

	/// Attach subviews to contentView to make a scrollable view
	public let contentView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Setup the views
	func setupViews() {

		backgroundColor = C.white()
	}

	/// Setup the hierarchy
	func setupViewHierarchy() {

		contentView.embed(in: self)
	}

	/// Setup the constraints
	func setupViewConstraints() {

		NSLayoutConstraint.activate([

			// Content
			contentView.widthAnchor.constraint(equalTo: widthAnchor),
			{
				let constraint = contentView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor)
				constraint.priority = .defaultLow
				return constraint
			}()
		])
	}
}

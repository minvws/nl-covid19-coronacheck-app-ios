/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScrollViewWithHeader: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let imageRatio: CGFloat = 0.75
	}

	/// The scrollview
	private let scrollView: UIScrollView = {

		let view = UIScrollView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let contentView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The header image
	let headerImageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFill
		view.clipsToBounds = true
		return view
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(scrollView)
		contentView.embed(in: scrollView)
		contentView.addSubview(headerImageView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Scroll
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

			// Content
			contentView.widthAnchor.constraint( equalTo: scrollView.widthAnchor),

			// Header image
			headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			headerImageView.heightAnchor.constraint(
				equalTo: headerImageView.widthAnchor,
				multiplier: ViewTraits.imageRatio
			)
		])
	}

	// MARK: Public Access

	/// The header image
	var headerImage: UIImage? {
		didSet {
			headerImageView.image = headerImage
		}
	}
}

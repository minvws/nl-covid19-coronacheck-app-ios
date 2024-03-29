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
 A borderd rectangular view to show a header and a text. Used for displaying the initials and birth day of a CTB. 
 */
open class IdentityElementView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let width: CGFloat = 56.0
		static let headerLineHeight: CGFloat = 16.0
		static let titleLineHeight: CGFloat = 28
		static let titleKerning: CGFloat = -0.20
		static let cornerRadius: CGFloat = 4.0

		// Margins
		static let marginBelowHeader: CGFloat = 6.0
		static let titleYOffset: CGFloat = 0
		static let minimalTextTopMargin: CGFloat = 4.0
		static let minimalTextMargin: CGFloat = 7.0

		// Styling
		static let borderHeight: CGFloat = 62.0
		static let borderWidth: CGFloat = 1.0
		static let headerAlignment: NSTextAlignment = .natural
		static let bodyFont: UIFont = Fonts.title2
		static let headerColor: UIColor = C.black() ?? .black

		static let hasContentBorderColor: UIColor = C.grey3() ?? .gray
		static let hasContentBackgroundColor: UIColor = C.white() ?? .white

		static let noContentBorderColor: UIColor = C.grey5() ?? .gray
		static let noContentBackgroundColor: UIColor = C.grey5() ?? .gray
	}

	/// Initialize the identity element view
	public init() {
		super.init(frame: .zero)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// The title label
	private let headerLabel: Label = {

		return Label(caption1SemiBold: nil).multiline()
	}()

	/// The bocy label
	private let bodyLabel: Label = {

		return Label(headlineBold: nil)
	}()

	private let borderView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override open func setupViews() {
		super.setupViews()

		borderView.layer.cornerRadius = ViewTraits.cornerRadius
		borderView.layer.borderWidth = ViewTraits.borderWidth
		bodyLabel.font = ViewTraits.bodyFont
		headerLabel.textColor = ViewTraits.headerColor

		updateStylingForContent()
	}

	func updateStylingForContent() {
		if body == nil {
			borderView.layer.borderColor = ViewTraits.noContentBorderColor.cgColor
			borderView.backgroundColor = ViewTraits.noContentBackgroundColor
		} else {
			borderView.layer.borderColor = ViewTraits.hasContentBorderColor.cgColor
			borderView.backgroundColor = ViewTraits.hasContentBackgroundColor
		}
	}

	/// Setup the hierarchy
	override open func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(headerLabel)
		addSubview(borderView)
		addSubview(bodyLabel)
	}

	/// Setup the constraints
	override open func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Header
			headerLabel.topAnchor.constraint(equalTo: topAnchor),
			headerLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor),
			headerLabel.trailingAnchor.constraint(equalTo: borderView.trailingAnchor),
			headerLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.headerLineHeight),

			// Border / Background
			borderView.topAnchor.constraint(
				equalTo: headerLabel.bottomAnchor,
				constant: ViewTraits.marginBelowHeader
			),
			borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
			borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
			borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
			borderView.widthAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.width),
			borderView.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.borderHeight),

			// Title
			bodyLabel.centerYAnchor.constraint(
				lessThanOrEqualTo: borderView.centerYAnchor,
				constant: -ViewTraits.titleYOffset
			),
			bodyLabel.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
			bodyLabel.leadingAnchor.constraint(
				greaterThanOrEqualTo: borderView.leadingAnchor,
				constant: ViewTraits.minimalTextMargin
			),
			bodyLabel.trailingAnchor.constraint(
				lessThanOrEqualTo: borderView.trailingAnchor,
				constant: -ViewTraits.minimalTextMargin
			),
			bodyLabel.topAnchor.constraint(
				greaterThanOrEqualTo: borderView.topAnchor,
				constant: ViewTraits.minimalTextTopMargin
			),
			bodyLabel.bottomAnchor.constraint(
				lessThanOrEqualTo: borderView.bottomAnchor,
				constant: -ViewTraits.minimalTextMargin
			)
		])
		
		borderView.setContentHuggingPriority(.required, for: .vertical)
	}

	// MARK: Public Access

	/// The title
	public var header: String? {
		didSet {
			headerLabel.attributedText = header?.setLineHeight(
				ViewTraits.headerLineHeight,
				alignment: ViewTraits.headerAlignment
			)
		}
	}

	/// The title
	public var body: String? {
		didSet {
			bodyLabel.attributedText = (self.body ?? "-").setLineHeight(
				ViewTraits.titleLineHeight,
				alignment: .center,
				kerning: ViewTraits.titleKerning
			)

			updateStylingForContent()
		}
	}
}

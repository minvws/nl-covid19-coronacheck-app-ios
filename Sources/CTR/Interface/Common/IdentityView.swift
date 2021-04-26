/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class IdentityElementView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let width: CGFloat = 56.0
		static let headerLineHeight: CGFloat = 16.0
		static let titleLineHeight: CGFloat = 28
		static let titleKerning: CGFloat = -0.20
		static let cornerRadius: CGFloat = 4.0

		// Margins
		static let margin: CGFloat = 10.0
		static let titleOffset: CGFloat = 2.0
		static let minimalTextTopMargin: CGFloat = 4.0
		static let minimalTextMargin: CGFloat = 7.0
	}

	/// Initialize the identity element view
	/// - Parameters:
	///   - borderHeight: the height of the border
	///   - borderWidth: the width of the border
	///   - borderColor: the color of the border
	///   - headerAlignment: the text alignment of the header text
	///   - bodyFont: the font of the body
	init(
		borderHeight: CGFloat = 44.0,
		borderWidth: CGFloat = 2.0,
		borderColor: UIColor = Theme.colors.dark,
		headerAlignment: NSTextAlignment = .center,
		bodyFont: UIFont = Theme.fonts.headlineBold) {

		self.borderHeight = borderHeight
		self.borderWidth = borderWidth
		self.borderColor = borderColor
		self.headerAlignment = headerAlignment
		self.bodyFont = bodyFont
		super.init(frame: .zero)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var borderWidth: CGFloat
	var borderHeight: CGFloat
	var borderColor: UIColor

	var headerAlignment: NSTextAlignment
	var bodyFont: UIFont

	/// The title label
	private let headerLabel: Label = {

		return Label(caption1SemiBold: nil)
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

	override func setupViews() {
		super.setupViews()

		borderView.layer.cornerRadius = ViewTraits.cornerRadius
		borderView.layer.borderWidth = borderWidth
		borderView.layer.borderColor = borderColor.cgColor
		bodyLabel.font = bodyFont
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(headerLabel)
		addSubview(borderView)
		addSubview(bodyLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

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
				constant: ViewTraits.margin
			),
			borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
			borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
			borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
			borderView.widthAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.width),
			borderView.heightAnchor.constraint(greaterThanOrEqualToConstant: borderHeight),

			// Title
			bodyLabel.centerYAnchor.constraint(
				lessThanOrEqualTo: borderView.centerYAnchor,
				constant: -ViewTraits.titleOffset
			),
			bodyLabel.centerXAnchor.constraint(equalTo: borderView.centerXAnchor),
			bodyLabel.leadingAnchor.constraint(
				greaterThanOrEqualTo: borderView.leadingAnchor,
				constant: ViewTraits.minimalTextMargin
			),
			bodyLabel.trailingAnchor.constraint(
				greaterThanOrEqualTo: borderView.trailingAnchor,
				constant: -ViewTraits.minimalTextMargin
			),
			bodyLabel.topAnchor.constraint(
				greaterThanOrEqualTo: borderView.topAnchor,
				constant: ViewTraits.minimalTextTopMargin
			)
		])
	}

	// MARK: Public Access

	/// The title
	var header: String? {
		didSet {
			headerLabel.attributedText = header?.setLineHeight(
				ViewTraits.headerLineHeight,
				alignment: headerAlignment
			)
		}
	}

	/// The title
	var body: String? {
		didSet {
			bodyLabel.attributedText = body?.setLineHeight(
				ViewTraits.titleLineHeight,
				alignment: .center,
				kerning: ViewTraits.titleKerning
			)
		}
	}
}

class IdentityView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let spacing: CGFloat = 12.0
	}

	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .horizontal
		view.alignment = .center
		view.distribution = .fill
		view.spacing = ViewTraits.spacing
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(stackView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		NSLayoutConstraint.activate([

			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor)
		])
	}

	// MARK: Public Access

	/// The identity elements (header, body)
	var elements: [(header: String, body: String)] = [] {
		didSet {
			for element in elements {
				let view = IdentityElementView()
				view.header = element.header
				view.body = element.body
				stackView.addArrangedSubview(view)
			}
		}
	}
}

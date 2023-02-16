/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Resources

class IdentitySelectionDetailsView: BaseView {
	
	/// The display constants
	enum ViewTraits {

		enum Margin {
			static let bottom: CGFloat = 48
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let titleToContentTextView: CGFloat = 24
			static let stackSpacing: CGFloat = 8
			static let headerToStackview: CGFloat = 24
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		enum Details {
			static let lineHeight: CGFloat = 17
			static let kerning: CGFloat = -0.41
		}
	}

	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()

	let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let detailsStackView: UIStackView = {

		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = ViewTraits.Spacing.stackSpacing
		return stackView
	}()
	
	private let spacer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(titleLabel)
		addSubview(contentTextView)
		addSubview(detailsStackView)
		addSubview(spacer)
	}

	override func setupViewConstraints() {

		super.setupViewConstraints()
		setupTitleLabelViewConstraints()
		setupContentTextViewConstraints()
		setupDetailsStackViewConstraints()
		setupSpacerViewConstraints()
	}

	func setupTitleLabelViewConstraints() {

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint( equalTo: topAnchor),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.Margin.edge
			),
			titleLabel.widthAnchor.constraint(
				equalTo: widthAnchor,
				constant: -2 * ViewTraits.Margin.edge
			)
		])
	}

	func setupContentTextViewConstraints() {

		NSLayoutConstraint.activate([
			contentTextView.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: ViewTraits.Spacing.titleToContentTextView
			),
			contentTextView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			contentTextView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.Margin.edge
			),
			contentTextView.widthAnchor.constraint(
				equalTo: widthAnchor,
				constant: -2 * ViewTraits.Margin.edge
			)
		])
	}

	func setupDetailsStackViewConstraints() {

		NSLayoutConstraint.activate([
			detailsStackView.topAnchor.constraint(
				equalTo: contentTextView.bottomAnchor,
				constant: ViewTraits.Spacing.headerToStackview
			),
			detailsStackView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			detailsStackView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.Margin.edge
			),
			detailsStackView.widthAnchor.constraint(
				equalTo: widthAnchor,
				constant: -2 * ViewTraits.Margin.edge
			),
			detailsStackView.bottomAnchor.constraint(
				equalTo: spacer.topAnchor,
				constant: -ViewTraits.Margin.bottom
			)
		])
	}
	
	func setupSpacerViewConstraints() {
		
		NSLayoutConstraint.activate([
			spacer.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor),
			spacer.leadingAnchor.constraint(equalTo: leadingAnchor),
			spacer.trailingAnchor.constraint(equalTo: trailingAnchor),
			spacer.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: UIDevice.current.hasNotch ? 0 : -ViewTraits.Margin.bottom
			)
		])
	}

	// MARK: Public Access

	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning,
				textColor: C.black()!)
		}
	}

	var message: String? {
		didSet {
			contentTextView.applyHTML(message)
		}
	}
	
	func addLabelToStackView(_ label: UILabel, customSpacing: CGFloat? = nil) {
		
		detailsStackView.addArrangedSubview(label)
		if let customSpacing {
			detailsStackView.setCustomSpacing(customSpacing, after: label)
		}
	}
}

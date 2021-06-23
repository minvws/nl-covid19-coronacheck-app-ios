/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import SwiftRichString

class InformationView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52

		// Margins
		static let margin: CGFloat = 20.0
	}

	/// The stackview
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.margin
		return view
	}()

	/// The title label
	private let titleLabel: Label = {
        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	/// The message label
	private let messageLabel: TextView = {
		return TextView()
	}()

	/// The bottom constraint
	var bottomConstraint: NSLayoutConstraint?

	/// setup the views
	override func setupViews() {

		super.setupViews()
		titleLabel.textColor = Theme.colors.dark
		backgroundColor = Theme.colors.viewControllerBackground
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)

		addSubview(stackView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			stackView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.margin
			),
			stackView.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			),
			stackView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The message
	var message: String? {
		didSet {

			guard let message = message else { return }


			let normal = Style {
				$0.font = Theme.fonts.body
				$0.color = Theme.colors.dark
			}

			let bold = Style {
				$0.font = Theme.fonts.bodyBold
				$0.color = UIColor.red
			}

			let italic = normal.byAdding {
				$0.traitVariants = .italic
			}

			let html = """
			<p>Travelling outside of the Netherlands? Then more data is required. That's why the international QR code contains the following details:</p>
			<p>Name: <b>Bouwer, Bob</b>
			Date of birth: <b>1 January 1960</b></p>
			<p>Pathogen: <b>COVID-19</b>
			<br />Vaccine: <b>MODERNA</b>
			<br />Vaccine type: <b>SARS-CoV-2 mRNA vaccine</b>
			<br />Manufacturer: <b>Biontech Manufacturing GmbH</b>
			<br />Doses: <b>2 of 2</b>
			<br />Date of injection: <b>21 June 2021</b>
			<br />Vaccinated in: <b>NL</b>
			<br />Identification code:
			</p>
			<p>Always use the international QR code in other countries. The Dutch QR code is not valid outside of the Netherlands.</p>

			"""

//			let html = "<html><head></head><body>"
//				+ (message
//				.replacingOccurrences(of: "<br>", with: "<br />")
//				.replacingOccurrences(of: "\\", with: "")
//				)
//				+ "</body></html>"

			let myGroup = StyleXML(base: normal, ["bold": bold, "italic": italic])
			messageLabel.attributedText = html.set(style: myGroup)





//			messageLabel.attributedText = .makeFromHtml(
//				text: message,
//				font: Theme.fonts.body,
//				textColor: Theme.colors.dark
//			)
		}
	}

	var linkTapHandler: ((URL) -> Void)? {
		didSet {
			guard let linkTapHandler = linkTapHandler else { return }
			messageLabel.linkTouched(handler: linkTapHandler)
		}
	}

	func handleScreenCapture(shouldHide: Bool) {
		messageLabel.isHidden = shouldHide
	}

}

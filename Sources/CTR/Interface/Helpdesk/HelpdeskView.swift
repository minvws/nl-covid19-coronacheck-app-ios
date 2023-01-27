/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class HelpdeskView: ScrolledStackView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		enum Subtitle {
			static let lineHeight: CGFloat = 12
			static let kerning: CGFloat = -0.26
		}
	}
		
	private let contactSubtitleLabel: Label = {

		return Label(title3: nil, montserrat: true).multiline().header()
	}()
	
	private let contactMessageStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 8
		return stackView
	}()
	
	private let contactMessageTextView1: TextView = {
		
		return TextView()
	}()
	
	private let contactMessageTextView2: TextView = {
		
		return TextView()
	}()
	
	private let contactMessageTextView3: TextView = {
		
		return TextView()
	}()
	
	private let supportSubtitleLabel: Label = {

		return Label(title3: nil, montserrat: true).multiline().header()
	}()
	
	private let supportMessageTextView: TextView = {

		return TextView()
	}()
		
	private let dividerView: UIView = {
		let view = UIView()
		view.backgroundColor = C.grey3a()
		return view
	}()
		
	private let appInfoStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		return stackView
	}()
	
	private let appVersionLabel: Label = {

		return Label(bodyBold: "").multiline()
	}()
	
	private let appVersionTextView: TextView = {

		return TextView()
	}()

	private let configurationLabel: Label = {

		return Label(bodyBold: "").multiline()
	}()
	
	private let configurationTextView: TextView = {

		return TextView()
	}()
		
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
		let linkTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: C.primaryBlue() as Any]
		contactMessageTextView1.linkTextAttributes = linkTextAttributes
		contactMessageTextView2.linkTextAttributes = linkTextAttributes
		contactMessageTextView3.linkTextAttributes = linkTextAttributes
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(contactSubtitleLabel)
		
		contactMessageStackView.addArrangedSubview(contactMessageTextView1)
		contactMessageStackView.addArrangedSubview(contactMessageTextView2)
		contactMessageStackView.addArrangedSubview(contactMessageTextView3)
		stackView.addArrangedSubview(contactMessageStackView)
		
		stackView.addArrangedSubview(dividerView)

		stackView.addArrangedSubview(supportSubtitleLabel)
		stackView.addArrangedSubview(supportMessageTextView)
 
		appInfoStackView.addArrangedSubview(appVersionLabel)
		appInfoStackView.addArrangedSubview(appVersionTextView)
		appInfoStackView.setCustomSpacing(20, after: appVersionTextView)
		appInfoStackView.addArrangedSubview(configurationLabel)
		appInfoStackView.addArrangedSubview(configurationTextView)
		stackView.addArrangedSubview(appInfoStackView)
	}
	
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
	}
	
	// MARK: Public Access
	
	var contactSubtitle: String? {
		didSet {
			contactSubtitleLabel.attributedText = contactSubtitle?.setLineHeight(
				ViewTraits.Subtitle.lineHeight,
				kerning: ViewTraits.Subtitle.kerning
			)
		}
	}
	
	var contactMessage1: String? {
		didSet {
			NSAttributedString.makeFromHtml(
				text: contactMessage1,
				style: NSAttributedString.HTMLStyle(
					font: Fonts.body,
					textColor: C.black()!,
					paragraphSpacing: 0
				)
			) {
				self.contactMessageTextView1.attributedText = $0
			}
		}
	}
	
	var contactMessage2: String? {
		didSet {
			NSAttributedString.makeFromHtml(
				text: contactMessage2,
				style: NSAttributedString.HTMLStyle(
					font: Fonts.body,
					textColor: C.black()!,
					paragraphSpacing: 0
				)
			) {
				self.contactMessageTextView2.attributedText = $0
			}
		}
	}
	
	var contactMessage3: String? {
		didSet {
			NSAttributedString.makeFromHtml(
				text: contactMessage3,
				style: NSAttributedString.HTMLStyle(
					font: Fonts.body,
					textColor: C.black()!,
					paragraphSpacing: 0
				)
			) {
				self.contactMessageTextView3.attributedText = $0
			}
		}
	}
	
	var supportSubtitle: String? {
		didSet {
			supportSubtitleLabel.attributedText = supportSubtitle?.setLineHeight(
				ViewTraits.Subtitle.lineHeight,
				kerning: ViewTraits.Subtitle.kerning
			)
		}
	}
	
	var supportMessage: String? {
		didSet {
			NSAttributedString.makeFromHtml(
				text: supportMessage,
				style: NSAttributedString.HTMLStyle(
					font: Fonts.body,
					textColor: C.black()!,
					paragraphSpacing: 0
				)
			) {
				self.supportMessageTextView.attributedText = $0
			}
		}
	}
	
	var appVersionTitle: String? {
		didSet {
			appVersionLabel.text = appVersionTitle
		}
	}
	
	var appVersion: String? {
		didSet {
			appVersionTextView.text = appVersion
		}
	}
	
	var configurationTitle: String? {
		didSet {
			configurationLabel.text = configurationTitle
		}
	}
	
	var configuration: String? {
		didSet {
			configurationTextView.text = configuration
		}
	}
	
	var urlTapHander: ((URL) -> Void)? {
		didSet {
			contactMessageTextView1.linkTouchedHandler = { [weak self] url in
				self?.urlTapHander?(url)
			}
			contactMessageTextView2.linkTouchedHandler = { [weak self] url in
				self?.urlTapHander?(url)
			}
			contactMessageTextView3.linkTouchedHandler = { [weak self] url in
				self?.urlTapHander?(url)
			}
		}
	}
}

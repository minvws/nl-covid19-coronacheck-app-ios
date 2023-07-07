/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckUI

class PDFExportCardView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		enum Image {
			static let width: CGFloat = 64.0
			static let height: CGFloat = 40.0
			static let topMargin: CGFloat = 40.0
		}
		enum Title {
			static let lineHeight: CGFloat = 28
			static let kerning: CGFloat = -0.26
			static let sideMargin: CGFloat = 24.0
			static let topMargin: CGFloat = 32.0
		}
		enum Message {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let sideMargin: CGFloat = 24.0
			static let topMargin: CGFloat = 16.0
		}
		enum PrimaryButton {
			static let topMargin: CGFloat = 24.0
			static let bottomMargin: CGFloat = 40.0
			static let height: CGFloat = 52.0
		}
		enum SecondaryButton {
			static let topMargin: CGFloat = 32.0
			static let sideMargin: CGFloat = 16.0
		}
	}
	
	private let imageView: UIImageView = {
		
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		view.image = I.pdF.international()
		return view
	}()
	
	private let titleLabel: Label = {
		
		return Label(title3: nil, montserrat: true).multiline().header()
	}()
	
	private let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()
	
	let primaryButton: Button = {
		return Button(title: "", style: .roundedBlue)
	}()

	private let secondaryButton: Button = {
		return Button(title: "", style: .textLabelBlue)
	}()
	
	override func setupViews() {
		
		super.setupViews()
		
		backgroundColor = C.white()
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		addSubview(imageView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(secondaryButton)
		addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.Image.topMargin),
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.widthAnchor.constraint(equalToConstant: ViewTraits.Image.width),
			imageView.heightAnchor.constraint(equalToConstant: ViewTraits.Image.height),
			
			titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.Title.sideMargin),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.Title.sideMargin),
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ViewTraits.Title.topMargin),
			
			messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.Message.sideMargin),
			messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.Message.sideMargin),
			messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ViewTraits.Message.topMargin),

			secondaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			secondaryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: ViewTraits.SecondaryButton.topMargin),
			secondaryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.SecondaryButton.sideMargin),
			secondaryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.SecondaryButton.sideMargin),
			
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.topAnchor.constraint(equalTo: secondaryButton.bottomAnchor, constant: ViewTraits.PrimaryButton.topMargin),
			primaryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.PrimaryButton.bottomMargin),
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.PrimaryButton.height)
		])
	}
	
	@objc private func primaryButtonTapped() {
		
		primaryButtonCommand?()
	}
	
	@objc private func secondaryButtonTapped() {
		
		secondaryButtonCommand?()
	}
	
	var primaryButtonCommand: (() -> Void)?
	
	var secondaryButtonCommand: (() -> Void)?
	
	var primaryButtonTitle: String? {
		didSet {
			primaryButton.title = primaryButtonTitle
		}
	}
	
	var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.title = secondaryButtonTitle
		}
	}
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				alignment: .center,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(
				ViewTraits.Message.lineHeight,
				alignment: .center,
				kerning: ViewTraits.Message.kerning
			)
		}
	}
}

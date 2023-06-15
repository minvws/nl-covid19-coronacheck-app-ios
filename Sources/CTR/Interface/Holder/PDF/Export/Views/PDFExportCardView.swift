/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Resources
import ReusableViews

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
		enum Button {
			static let topMargin: CGFloat = 32.0
			static let bottomMargin: CGFloat = 40.0
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
	
	private let actionButton: Button = {
		return Button(title: "", style: .roundedBlue)
	}()
	
	override func setupViews() {
		
		super.setupViews()
		
		backgroundColor = C.white()
		actionButton.touchUpInside(self, action: #selector(actionButtonTapped))
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		addSubview(imageView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(actionButton)
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
			messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ViewTraits.Title.topMargin),
			
			actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: ViewTraits.Button.topMargin),
			actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.Button.bottomMargin)
			
		])
	}
	
	@objc private func actionButtonTapped() {
		
		actionButtonCommand?()
	}
	
	var actionButtonCommand: (() -> Void)?
	
	var actionButtonTitle: String? {
		didSet {
			actionButton.title = actionButtonTitle
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

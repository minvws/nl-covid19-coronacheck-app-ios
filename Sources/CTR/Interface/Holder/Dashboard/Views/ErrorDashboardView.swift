/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class ErrorDashboardView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Color {
			static let tint: UIColor = Theme.colors.utilityError
		}
		enum Font {
			static let font: UIFont = Theme.fonts.subhead
			static let lineHeight: CGFloat = 20
			static let kern: CGFloat = 0.25
			static let paragraphSpacing: CGFloat = -3
		}
		enum Spacing {
			static let iconToMessage: CGFloat = 8
		}
		enum Size {
			static let icon: CGFloat = 12
		}
	}
	
	private let iconImageView: UIImageView = {
		let imageView = UIImageView(image: I.dashboard.error_Dashboard())
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.tintColor = ViewTraits.Color.tint
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	let messageTextView: TextView = {
		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.linkTextAttributes = [.foregroundColor: ViewTraits.Color.tint]
		return view
	}()
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(iconImageView)
		addSubview(messageTextView)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		let iconOffset = ViewTraits.Font.lineHeight - ViewTraits.Font.font.ascender
		
		NSLayoutConstraint.activate([
			iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: iconOffset),
			iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
			iconImageView.widthAnchor.constraint(equalToConstant: ViewTraits.Size.icon),
			iconImageView.heightAnchor.constraint(equalToConstant: ViewTraits.Size.icon),
			
			messageTextView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: ViewTraits.Spacing.iconToMessage),
			messageTextView.topAnchor.constraint(equalTo: topAnchor),
			messageTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
			messageTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	var message: String? {
		didSet {
			messageTextView.attributedText = .makeFromHtml(
				text: message,
				font: Theme.fonts.subhead,
				textColor: ViewTraits.Color.tint,
				lineHeight: ViewTraits.Font.lineHeight,
				kern: ViewTraits.Font.kern,
				paragraphSpacing: ViewTraits.Font.paragraphSpacing
			)
		}
	}
}

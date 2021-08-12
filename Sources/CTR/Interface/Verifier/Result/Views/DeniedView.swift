/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DeniedView: ScrolledStackWithButtonView {
	
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 4
		}
		enum Spacing {
			static let imageToLabel: CGFloat = UIDevice.current.isSmallScreen ? 24 : 40
		}
		enum Size {
			static let imageWidth: CGFloat = 200
		}
	}
	
	private let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		view.image = .denied
		return view
	}()
	
	private let titleLabel: Label = {

		let label = Label(title1: nil, montserrat: true).multiline().header()
		label.textAlignment = .center
		label.textColor = Theme.colors.dark
		return label
	}()
	
	private let secondaryButton: Button = {

		let button = Button()
		button.rounded = true
		button.titleLabel?.textAlignment = .center
		return button
	}()
	
	override func setupViews() {
		super.setupViews()
	
		stackView.spacing = ViewTraits.Spacing.imageToLabel
		stackViewInset.top = ViewTraits.Margin.top
		
		actionColor = Theme.colors.denied
		footerActionColor = Theme.colors.denied
		
		primaryButton.style = .secondary
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(titleLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		setupPrimaryButton(useFullWidth: {
			switch traitCollection.preferredContentSizeCategory {
				case .unspecified: return true
				case let size where size > .extraLarge: return true
				default: return false
			}
		}())
		
		// Disable the bottom constraint of the scroll view, add our own
		bottomScrollViewConstraint?.isActive = false
		
		NSLayoutConstraint.activate([
			
			scrollView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor),
			
			imageView.widthAnchor.constraint(equalToConstant: ViewTraits.Size.imageWidth)
		])
	}
	
	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}
}

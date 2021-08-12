/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DeniedView: ScrolledStackWithButtonView {
	
	private enum ViewTraits {
		
		enum Size {
			static let image = CGSize(width: 200, height: 200)
		}
	}
	
	private let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()
	
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let secondaryButton: Button = {

		let button = Button()
		button.rounded = true
		button.titleLabel?.textAlignment = .center
		return button
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.denied
		imageView.image = .denied
		
		primaryButton.style = .secondary
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		
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
			
			scrollView.bottomAnchor.constraint(equalTo: footerBackground.topAnchor)
		])
	}
}

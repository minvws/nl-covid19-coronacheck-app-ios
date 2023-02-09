/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import ReusableViews

/// Component is to get left to right accessibility VoiceOver focus order
final class ShowQRNavigationInfoView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		enum Dimension {
			static let pageButton: CGFloat = 60
		}
		enum Spacing {
			static let dosageToButton: CGFloat = 10
		}
	}
	
	/// The info button
	let nextButton: TappableButton = {
		
		let button = TappableButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(I.pageIndicatorNext(), for: .normal)
		button.setupLargeContentViewer(title: L.holderShowqrNextbutton())
		return button
	}()
	
	/// The info button
	let previousButton: TappableButton = {
		
		let button = TappableButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(I.pageIndicatorBack(), for: .normal)
		button.setupLargeContentViewer(title: L.holderShowqrPreviousbutton())
		return button
	}()
	
	/// The title label
	let dosageLabel: Label = {
		
		return Label(headlineBold: nil, montserrat: true).multiline()
	}()
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(previousButton)
		addSubview(dosageLabel)
		addSubview(nextButton)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			nextButton.widthAnchor.constraint(equalToConstant: ViewTraits.Dimension.pageButton),
			nextButton.heightAnchor.constraint(equalToConstant: ViewTraits.Dimension.pageButton),
			nextButton.centerYAnchor.constraint(equalTo: dosageLabel.centerYAnchor),
			nextButton.trailingAnchor.constraint(equalTo: trailingAnchor),
			
			previousButton.widthAnchor.constraint(equalToConstant: ViewTraits.Dimension.pageButton),
			previousButton.heightAnchor.constraint(equalToConstant: ViewTraits.Dimension.pageButton),
			previousButton.centerYAnchor.constraint(equalTo: dosageLabel.centerYAnchor),
			previousButton.leadingAnchor.constraint(equalTo: leadingAnchor),
			
			dosageLabel.topAnchor.constraint(
				equalTo: topAnchor
			),
			dosageLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor
			),
			dosageLabel.leadingAnchor.constraint(
				greaterThanOrEqualTo: previousButton.trailingAnchor,
				constant: ViewTraits.Spacing.dosageToButton
			),
			dosageLabel.trailingAnchor.constraint(
				lessThanOrEqualTo: nextButton.leadingAnchor,
				constant: -ViewTraits.Spacing.dosageToButton
			),
			dosageLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
	
	override func setupAccessibility() {
		super.setupAccessibility()
		
		// Force left to right focus order
		accessibilityElements = [previousButton, dosageLabel, nextButton]
		previousButton.accessibilityIdentifier = "BackButton"
		nextButton.accessibilityIdentifier = "NextButton"
	}
}

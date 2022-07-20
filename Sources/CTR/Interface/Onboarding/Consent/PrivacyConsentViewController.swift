/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class PrivacyConsentViewController: TraitWrappedGenericViewController<PrivacyConsentView, PrivacyConsentViewModel> {
	
	override var enableSwipeBack: Bool { !viewModel.shouldHideBackButton }
	
	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		viewModel.$message.binding = { [weak self] in self?.sceneView.message = $0 }
		
		sceneView.contentTextView.linkTouchedHandler = { [weak self] url in
			
			self?.viewModel.openUrl(url)
		}

		viewModel.$actionTitle.binding = { [weak self] in self?.sceneView.primaryButton.setTitle($0, for: .normal) }
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))

		viewModel.$consentText.binding = { [weak self] in self?.sceneView.consent = $0 }
		viewModel.$consentNotGivenError.binding = { [weak self] in self?.sceneView.consentError = $0 }
		self.sceneView.consentButton.valueChanged(self, action: #selector(consentValueChanged))

		viewModel.$summary.binding = { [weak self] in

			let total = $0.count
			for (index, item) in $0.enumerated() {
				self?.sceneView.addPrivacyItem(item, number: index + 1, total: total)
			}
		}
		viewModel.$shouldHideBackButton.binding = { [weak self] in if !$0 { self?.addBackButton() } }
		viewModel.$shouldHideConsentButton.binding = { [weak self] in if !$0 { self?.sceneView.setupConsentButton() } }
		viewModel.$shouldDisplayConsentError.binding = { [weak self] shouldDisplayError in
			
			self?.sceneView.hasErrorState = shouldDisplayError
			
			if shouldDisplayError {
				DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
					UIAccessibility.post(notification: .announcement, argument: self?.viewModel.consentNotGivenError)
				}
			}
		}
	}

	/// User tapped on the consent button
	@objc func consentValueChanged(_ sender: LabelWithCheckbox) {

		// Hide error
		guard sender.isSelected else { return }
		viewModel.consentGiven(true)
	}

	/// The user tapped on the primary button
	@objc func primaryButtonTapped() {

		if sceneView.consentButton.isSelected || viewModel.shouldHideConsentButton {
			viewModel.primaryButtonTapped()
		} else {
			// Display error
			viewModel.consentGiven(false)
		}
	}
}

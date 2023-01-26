/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class IdentitySelectionDetailsViewController: TraitWrappedGenericViewController<IdentitySelectionDetailsView, IdentitySelectionDetailsViewModel> {
	
	override func viewDidLoad() {

		super.viewDidLoad()
		setupBinding()
	}
	
	private func setupBinding() {
		
		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }
		viewModel.details.observe { [weak self] details in
			for detail in details {
		
				for (index, element) in detail.enumerated() {
					
					if index == 0 {
						let label = Label(bodyBold: "").multiline().header()
						label.attributedText = element.setLineHeight(
							IdentitySelectionDetailsView.ViewTraits.Details.lineHeight,
							kerning: IdentitySelectionDetailsView.ViewTraits.Details.kerning,
							textColor: C.black() ?? .darkText
						)
						self?.sceneView.addLabelToStackView(label)
					} else {
						let label = Label(body: "").multiline()
						label.attributedText = element.setLineHeight(
							IdentitySelectionDetailsView.ViewTraits.Details.lineHeight,
							kerning: IdentitySelectionDetailsView.ViewTraits.Details.kerning,
							textColor: C.secondaryText() ?? .gray
						)
						self?.sceneView.addLabelToStackView(label, customSpacing: index == detail.count - 1 ? 24.0 : nil)
					}
				}
			}
		}
	}
}

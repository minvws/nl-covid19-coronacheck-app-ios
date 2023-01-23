/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

class HelpdeskViewController: TraitWrappedGenericViewController<HelpdeskView, HelpdeskViewModel> {
	
	override func viewDidLoad() {

		super.viewDidLoad()
		// The animation is squiffy otherwise
		if #available(iOS 15.0, *) {
			navigationItem.largeTitleDisplayMode = .always
		}
		title = L.holder_helpdesk_title()
		
		setupBindings()
		addBackButton()
	}
	
	func setupBindings() {

		sceneView.contactSubtitle = L.holder_helpdesk_contact_title()
		viewModel.$messageLine1.binding = { [weak self] in self?.sceneView.contactMessage1 = $0 }
		viewModel.$messageLine2.binding = { [weak self] in self?.sceneView.contactMessage2 = $0 }
		viewModel.$messageLine3.binding = { [weak self] in self?.sceneView.contactMessage3 = $0 }
		sceneView.supportSubtitle = L.holder_helpdesk_support_title()
		sceneView.supportMessage = L.holder_helpdesk_support_message()
		
		sceneView.appVersionTitle = L.holder_helpdesk_appVersion()
		sceneView.appVersion = viewModel.appVersion
		sceneView.configurationTitle = L.holder_helpdesk_configuration()
		sceneView.configuration = viewModel.configVersion
		
		sceneView.urlTapHander = { [weak viewModel] in
			viewModel?.userDidTapURL(url: $0)
		}
	}
}

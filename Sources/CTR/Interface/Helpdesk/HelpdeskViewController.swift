/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class HelpdeskViewController: TraitWrappedGenericViewController<HelpdeskView, HelpdeskViewModel> {
	
	override func viewDidLoad() {

		super.viewDidLoad()
		navigationItem.largeTitleDisplayMode = .always
		title = L.holder_helpdesk_title()
		
		setupBindings()
		addBackButton()
	}
	
	func setupBindings() {

		sceneView.contactSubtitle = L.holder_helpdesk_contact_title()
		sceneView.contactMessage1 = L.holder_helpdesk_contact_message_line1()
		sceneView.contactMessage2 = L.holder_helpdesk_contact_message_line2()
		sceneView.contactMessage3 = L.holder_helpdesk_contact_message_line3()
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

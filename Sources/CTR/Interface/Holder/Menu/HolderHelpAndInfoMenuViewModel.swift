/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Resources

class HolderHelpAndInfoMenuViewModel: MenuViewModel {
	
	private weak var coordinator: HolderCoordinatorDelegate?
	
	init(_ coordinator: HolderCoordinatorDelegate) {
		
		super.init(title: L.holder_helpInfo_title(), items: [])
		self.coordinator = coordinator
		setupMenuItems()
	}
	
	func setupMenuItems() {
		
		let itemFAQ: MenuViewModel.Item = .row(title: L.holderMenuFaq(), subTitle: nil, icon: I.icon_menu_faq()!, overrideColor: nil) { [weak coordinator] in
			guard let faqUrl = URL(string: L.holderUrlFaq()) else { return }
			coordinator?.openUrl(faqUrl, inApp: true)
		}
		
		let itemHelpdesk: MenuViewModel.Item = .row(title: L.holder_helpInfo_helpdesk(), subTitle: nil, icon: I.icon_menu_call()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToSeeHelpdesk()
		}
		
		let itemAboutThisApp: MenuViewModel.Item = .row(title: L.holderMenuAbout(), subTitle: nil, icon: I.icon_menu_phone()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToSeeAboutThisApp()
		}
		
		items = [
			itemFAQ,
			itemHelpdesk,
			.sectionBreak,
			itemAboutThisApp
		]
	}
}

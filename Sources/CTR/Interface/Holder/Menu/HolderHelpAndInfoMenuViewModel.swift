/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Resources
import Shared

class HolderHelpAndInfoMenuViewModel: MenuViewModelProtocol {
	
	private weak var coordinator: HolderCoordinatorDelegate?
	
	var title = Shared.Observable(value: L.holder_helpInfo_title())
	var items = Shared.Observable<[Item]>(value: [])
	
	init(_ coordinator: HolderCoordinatorDelegate) {
		
		self.coordinator = coordinator
		self.items.value = createMenuItems()
	}
	
	func createMenuItems() -> [Item] {
		
		let itemFAQ: Item = .row(title: L.holderMenuFaq(), subTitle: nil, icon: I.icon_menu_faq()!, overrideColor: nil) { [weak coordinator] in
			guard let faqUrl = URL(string: L.holderUrlFaq()) else { return }
			coordinator?.openUrl(faqUrl)
		}
		
		let itemHelpdesk: Item = .row(title: L.holder_helpInfo_helpdesk(), subTitle: nil, icon: I.icon_menu_call()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToSeeHelpdesk()
		}
		
		let itemAboutThisApp: Item = .row(title: L.holderMenuAbout(), subTitle: nil, icon: I.icon_menu_phone()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToSeeAboutThisApp()
		}
		
		return [
			itemFAQ,
			itemHelpdesk,
			.sectionBreak,
			itemAboutThisApp
		]
	}
}

/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Resources
import Models
import Shared

class VerifierMainMenuViewModel: MenuViewModelProtocol {
	
	private weak var coordinator: VerifierCoordinatorDelegate?
	
	var title = Shared.Observable(value: L.general_menu())
	var items = Shared.Observable<[Item]>(value: [])
	
	init(_ coordinator: VerifierCoordinatorDelegate) {
		
		self.coordinator = coordinator
		self.items.value = createMenuItems()
	}
	
	func createMenuItems() -> [Item] {
		
		let itemScanInstructions: Item = .row(title: L.verifierMenuScaninstructions(), subTitle: nil, icon: I.icon_menu_exclamation()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.navigateToScanInstruction(allowSkipInstruction: false)
		}
		
		let itemRiskSetting: Item = .row(title: L.verifier_menu_risksetting(), subTitle: nil, icon: I.icon_menu_risklevel()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.navigateToOpenRiskLevelSettings()
		}
		
		let itemFAQ: Item = .row(title: L.verifierMenuSupport(), subTitle: nil, icon: I.icon_menu_faq()!, overrideColor: nil) { [weak coordinator] in
			guard let faqUrl = URL(string: L.verifierUrlFaq()) else { return }
			coordinator?.openUrl(faqUrl)
		}
		
		let itemHelpdesk: Item = .row(title: L.holder_helpInfo_helpdesk(), subTitle: nil, icon: I.icon_menu_call()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToSeeHelpdesk()
		}
		
		let itemAboutThisApp: Item = .row(title: L.verifierMenuAbout(), subTitle: nil, icon: I.icon_menu_phone()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.navigateToAboutThisApp()
		}
		
		var verifierItems = [Item]()
		verifierItems += [itemScanInstructions]
		if Current.featureFlagManager.areMultipleVerificationPoliciesEnabled() {
			verifierItems += [itemRiskSetting]
		}
		verifierItems += [.sectionBreak, itemFAQ, itemHelpdesk]
		verifierItems += [.sectionBreak, itemAboutThisApp]
		return verifierItems
	}
}

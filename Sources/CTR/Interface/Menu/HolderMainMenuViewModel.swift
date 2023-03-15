/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Resources
import Models

class HolderMainMenuViewModel: MenuViewModel {
	
	private weak var coordinator: HolderCoordinatorDelegate?
	
	init(_ coordinator: HolderCoordinatorDelegate) {
		
		super.init(items: [])
		self.coordinator = coordinator
		setupMenuItems()
	}
	
	func setupMenuItems() {
		
		let itemAddCertificate: MenuViewModel.Item = .row(title: L.holder_menu_listItem_addVaccinationOrTest_title(), subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToCreateAQR()
		}
		
		let itemAddPaperCertificate: MenuViewModel.Item = .row(title: L.holder_menu_paperproof_title(), subTitle: L.holder_menu_paperproof_subTitle(), icon: I.icon_menu_addpapercertificate()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToAddPaperProof()
		}
		
		let itemAddVisitorPass: MenuViewModel.Item = .row(title: L.holder_menu_visitorpass(), subTitle: nil, icon: I.icon_menu_addvisitorpass()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToAddVisitorPass()
		}
		
		let itemStoredData: MenuViewModel.Item = .row(title: L.holder_menu_storedEvents(), subTitle: nil, icon: I.icon_menu_storeddata()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToSeeStoredEvents()
		}
		
		let itemHelpAndInfo: MenuViewModel.Item = .row(title: L.holder_menu_helpInfo(), subTitle: nil, icon: I.icon_menu_exclamation()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToSeeHelpAndInfoMenu()
		}
		
		let debugItemResetApp: MenuViewModel.Item = .row(title: L.holder_menu_resetApp(), subTitle: nil, icon: I.icon_menu_warning()!, overrideColor: C.ccError()) { [weak coordinator] in
			Current.wipePersistedData(flavor: .holder)
			coordinator?.userWishesToRestart()
		}
		
		var holderItems = [MenuViewModel.Item]()
		holderItems += [itemAddCertificate]
		holderItems += [itemAddPaperCertificate]
		if Current.featureFlagManager.isVisitorPassEnabled() {
			holderItems += [itemAddVisitorPass]
		}
		
		holderItems += [.sectionBreak]
		holderItems += [itemStoredData]
		holderItems += [itemHelpAndInfo]
		
		if Configuration().getEnvironment() != "production" {
			holderItems += [.sectionBreak]
			holderItems += [debugItemResetApp]
		}
		items = holderItems
	}
}

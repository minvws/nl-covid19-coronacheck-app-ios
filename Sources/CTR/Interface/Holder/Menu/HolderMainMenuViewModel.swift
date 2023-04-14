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

class HolderMainMenuViewModel: MenuViewModelProtocol {
	
	private weak var coordinator: HolderCoordinatorDelegate?
	
	var title = Shared.Observable(value: L.general_menu())
	var items = Shared.Observable<[Item]>(value: [])
	
	init(_ coordinator: HolderCoordinatorDelegate) {
		
		self.coordinator = coordinator
		self.items.value = createMenuItems()
	}
	
	func createMenuItems() -> [Item] {
		
		let itemAddCertificate: Item = .row(title: L.holder_menu_listItem_addVaccinationOrTest_title(), subTitle: nil, icon: I.icon_menu_add()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToCreateAQR()
		}
		
		let itemAddPaperCertificate: Item = .row(title: L.holder_menu_paperproof_title(), subTitle: L.holder_menu_paperproof_subTitle(), icon: I.icon_menu_addpapercertificate()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToAddPaperProof()
		}
		
		let itemStoredData: Item = .row(title: L.holder_menu_storedEvents(), subTitle: nil, icon: I.icon_menu_storeddata()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToSeeStoredEvents()
		}
		
		let itemHelpAndInfo: Item = .row(title: L.holder_menu_helpInfo(), subTitle: nil, icon: I.icon_menu_exclamation()!, overrideColor: nil) { [weak coordinator] in
			coordinator?.userWishesToSeeHelpAndInfoMenu()
		}
		
		let debugItemResetApp: Item = .row(title: L.holder_menu_resetApp(), subTitle: nil, icon: I.icon_menu_warning()!, overrideColor: C.ccError()) { [weak coordinator] in
			Current.wipePersistedData(flavor: .holder)
			coordinator?.userWishesToRestart()
		}
		
		var holderItems = [Item]()
		holderItems += [itemAddCertificate]
		holderItems += [itemAddPaperCertificate]
		
		holderItems += [.sectionBreak]
		holderItems += [itemStoredData]
		holderItems += [itemHelpAndInfo]
		
		if Configuration().getRelease() != .production {
			holderItems += [.sectionBreak]
			holderItems += [debugItemResetApp]
		}
		return holderItems
	}
}

/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

class PagedAnnouncementViewModel {
	
	weak var delegate: PagedAnnouncementDelegate?
	
	let shouldShowWithVWSRibbon: Bool
	private let itemsShouldShowWithFullWidthHeaderImage: Bool
	
	/// The pages for onboarding
	@Bindable private(set) var pages: [PagedAnnoucementItem]
	@Bindable private(set) var enabled: Bool
	
	init(
		delegate: PagedAnnouncementDelegate,
		pages: [PagedAnnoucementItem],
		itemsShouldShowWithFullWidthHeaderImage: Bool,
		shouldShowWithVWSRibbon: Bool
	) {
		
		self.delegate = delegate
		self.pages = pages
		self.enabled = true
		self.shouldShowWithVWSRibbon = shouldShowWithVWSRibbon
		self.itemsShouldShowWithFullWidthHeaderImage = itemsShouldShowWithFullWidthHeaderImage
	}
	
	/// Add an onboarding step
	/// - Parameter info: the info for the onboarding step
	func getStep(_ item: PagedAnnoucementItem) -> UIViewController {
		
		let viewController = PagedAnnouncementItemViewController(
			viewModel: PagedAnnouncementItemViewModel(
				item: item
			),
			shouldShowWithFullWidthHeaderImage: itemsShouldShowWithFullWidthHeaderImage
		)
		viewController.sceneView.imageBackgroundColor = item.imageBackgroundColor
		viewController.isAccessibilityElement = true
		return viewController
	}
	
	func primaryButtonTitle(forStep step: Int) -> String {
		if let title = pages[step].nextButtonTitle {
			return title
		} else if step == (pages.count - 1) {
			return L.general_toMyOverview()
		} else {
			return L.generalNext()
		}
	}
	
	/// User has finished viewing the finished the pages
	func finish() {
		
		delegate?.didFinishPagedAnnouncement()
	}
	
	func closeButtonTapped() {
		
		delegate?.didFinishPagedAnnouncement()
	}
}

/*
* Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Shared
import Resources
import ReusableViews

class MigrationStartViewModel: ContentWithImageProtocol {
	
	var content: Shared.Observable<ReusableViews.ContentWithImageViewController.Content>
	
	init(coordinator: MigrationCoordinatorDelegate) {
		
		content = Shared.Observable(
			value: ReusableViews.ContentWithImageViewController.Content(
				title: L.holder_startMigration_onboarding_title(),
				body: L.holder_startMigration_onboarding_message(),
				primaryAction: ContentWithImageViewController.Action(
					title: L.holder_startMigration_onboarding_nextButton(),
					action: { [weak coordinator] in
						coordinator?.userCompletedStart()
					}
				),
				image: I.migration()
			)
		)
	}
}

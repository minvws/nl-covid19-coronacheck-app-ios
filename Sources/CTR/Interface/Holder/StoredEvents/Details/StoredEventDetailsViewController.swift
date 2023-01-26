/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class StoredEventDetailsViewController: GenericViewController<StoredEventDetailsView, RemoteEventDetailsViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()
		
		addBackButton()

		viewModel.$title.binding = { [weak self] in self?.sceneView.title = $0 }
		
		viewModel.$details.binding = { [weak self] in self?.sceneView.details = $0 }

		viewModel.$hideForCapture.binding = { [weak self] in self?.sceneView.handleScreenCapture(shouldHide: $0) }
	}
}

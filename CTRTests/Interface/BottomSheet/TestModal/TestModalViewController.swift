/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
@testable import CTR

final class TestModalViewController: GenericViewController<TestModalView, TestModalViewModel> {
		
	override func viewDidLoad() {

		super.viewDidLoad()
		
		viewModel.$testTitle.binding = { [weak self] in self?.sceneView.testTitle = $0 }
		viewModel.$testMessage.binding = { [weak self] in self?.sceneView.testMessage = $0 }
	}
}

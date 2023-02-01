/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import WebKit
import Shared

public class WebViewController: TraitWrappedGenericViewController<WebView, WebViewModel> {
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		viewModel.urlRequest.observe { [weak self] in self?.sceneView.webView.load($0) }
		
		addBackButton()
	}
}

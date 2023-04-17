/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import WebKit
import ReusableViews
import Shared

class WebViewController: TraitWrappedGenericViewController<WebView, WebViewModel>, WKUIDelegate {

	override func viewDidLoad() {

		super.viewDidLoad()
		
		addBackButton()
		sceneView.webView.uiDelegate = self
		sceneView.webView.navigationDelegate = self
		
		viewModel.title.observe { [weak self] title in
			self?.title = title
		}
		
		viewModel.url.observe { [weak self] url in
			let request = URLRequest(url: url)
			self?.sceneView.webView.load(request)
		}
	}
}

extension WebViewController: WKNavigationDelegate {
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if let url = navigationAction.request.url {
			
			if viewModel.isDomainAllowed(url) {
				decisionHandler(.allow)
			} else {
				viewModel.handleUnallowedDomain(url)
				decisionHandler(.cancel)
			}
			return
		}
		decisionHandler(.cancel)
	}
}

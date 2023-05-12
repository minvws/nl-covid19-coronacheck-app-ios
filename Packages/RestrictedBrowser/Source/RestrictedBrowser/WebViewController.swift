/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import WebKit
import Resources
import ReusableViews

class WebViewController: TraitWrappedGenericViewController<WebView, WebViewModel> {

	override func viewDidLoad() {

		super.viewDidLoad()
		
		addBackButton()
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

// MARK: - WKNavigationDelegate -

extension WebViewController: WKNavigationDelegate {
	
	func webView(
		_ webView: WKWebView,
		decidePolicyFor navigationAction: WKNavigationAction,
		decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
			
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
	
	func webView(
		_ webView: WKWebView,
		didReceive challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		
		// See https://stackoverflow.com/a/51667317/443270
		
		guard let hostname = webView.url?.host else {
			return
		}

		let authenticationMethod = challenge.protectionSpace.authenticationMethod
		if authenticationMethod == NSURLAuthenticationMethodDefault || authenticationMethod == NSURLAuthenticationMethodHTTPBasic || authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
			let av = UIAlertController(title: webView.title, message: L.holder_login(hostname), preferredStyle: .alert)
			av.addTextField(configurationHandler: { textField in
				textField.placeholder = L.generalUsername()
			})
			av.addTextField(configurationHandler: { textField in
				textField.placeholder = L.generalPassword()
				textField.isSecureTextEntry = true
			})

			av.addAction(UIAlertAction(title: L.generalOk(), style: .default, handler: { action in
				guard let userId = av.textFields?.first?.text else {
					return
				}
				guard let password = av.textFields?.last?.text else {
					return
				}
				let credential = URLCredential(user: userId, password: password, persistence: .none)
				completionHandler(.useCredential, credential)
			}))
			av.addAction(UIAlertAction(title: L.general_cancel(), style: .cancel, handler: { _ in
				completionHandler(.cancelAuthenticationChallenge, nil)
			}))
			self.parent?.present(av, animated: true, completion: nil)
		} else if authenticationMethod == NSURLAuthenticationMethodServerTrust {
			completionHandler(.performDefaultHandling, nil)
		} else {
			completionHandler(.cancelAuthenticationChallenge, nil)
		}
	}
}

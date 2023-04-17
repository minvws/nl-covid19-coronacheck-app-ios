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
import Shared

class WebView: BaseView {
	
	let webView: WKWebView = {
		
		let webConfiguration = WKWebViewConfiguration()
		let view = WKWebView(frame: .zero, configuration: webConfiguration)
		return view
	}()
	
	override func setupViews() {
		super.setupViews()
		backgroundColor = C.white()
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(webView)
	}
	
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		webView.embed(in: safeAreaLayoutGuide)
	}
}

class WebViewModel {
	
	var title: Observable<String?>
	var url: Observable<URL>
	private var decider: AllowedDomain
	
	init(url: URL, title: String?, domainDecider: AllowedDomain) {
		
		self.title = Observable(value: title)
		self.url = Observable(value: url)
		self.decider = domainDecider
	}
	
	func isDomainAllowed(_ url: URL) -> Bool {
		return decider.isDomainAllowed(url)
	}
	
	func handleUnallowedDomain(_ url: URL) {
		return decider.handleUnallowedDomain(url)
	}
}

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
				print("WKNavigationDelegate allow navigating to \(url.absoluteString)")
				decisionHandler(.allow)
			} else {
				print("WKNavigationDelegate do not allow navigating to \(url.absoluteString)")
				viewModel.handleUnallowedDomain(url)
				decisionHandler(.cancel)
			}
			return
		}
		decisionHandler(.cancel)
	}
}

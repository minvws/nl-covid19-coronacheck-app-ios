/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import ReusableViews
import WebKit

class PDFExportViewController: TraitWrappedGenericViewController<PDFExportView, PDFExportViewModel> {
	
	static let postMessageIdentifier: String = "coronacheck"
	
	var webView: WKWebView?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		addBackButton(customAction: nil)
		
		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }
		sceneView.messageTextView.linkTouchedHandler = { [weak self] url in
			
			self?.viewModel.openUrl(url)
		}
		
		viewModel.html.observe { [weak self] in
			guard let html = $0 else { return }
			self?.setupWebView(html: html)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		viewModel.viewDidAppear()
	}
	
	func setupWebView(html: String) {
		
		let contentController = WKUserContentController()
		contentController.add(self, name: PDFExportViewController.postMessageIdentifier)

		let webConfiguration = WKWebViewConfiguration()
		webConfiguration.userContentController = contentController
		webConfiguration.preferences.javaScriptEnabled = true
		webView = WKWebView(frame: .zero, configuration: webConfiguration)

		sceneView.stackView.addArrangedSubview(webView!)
		webView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
		webView?.loadHTMLString(html, baseURL: nil)
	}
}

// MARK: WKScriptMessageHandler

extension PDFExportViewController: WKScriptMessageHandler {
	
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		
		viewModel.handleMessage(message: message)
	}
}

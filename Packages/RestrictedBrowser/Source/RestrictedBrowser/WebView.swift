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

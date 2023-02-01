/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import WebKit
import Shared

public class WebView: BaseView {
	
	public let webView: WKWebView = {

		let webConfiguration = WKWebViewConfiguration()
		let view = WKWebView(frame: .zero, configuration: webConfiguration)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override open func setupViews() {
		
		super.setupViews()
		self.backgroundColor = C.white()
	}
	
	override open func setupViewHierarchy() {

		super.setupViewHierarchy()
		webView.embed(in: self.safeAreaLayoutGuide)
	}
}

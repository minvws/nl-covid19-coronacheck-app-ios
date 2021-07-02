/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import WebKit

class InformationView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52

		// Margins
		static let margin: CGFloat = 20.0
	}

	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.margin
		return view
	}()

	private let titleLabel: Label = {
        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	private lazy var webView: WKWebView = {
		let webView = WKWebView()
		webView.navigationDelegate = self
		webView.scrollView.showsHorizontalScrollIndicator = false
		return webView
	}()

	var bottomConstraint: NSLayoutConstraint?

	override func setupViews() {

		super.setupViews()
		titleLabel.textColor = Theme.colors.dark
		backgroundColor = Theme.colors.viewControllerBackground
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(webView)

		addSubview(stackView)
	}

	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			stackView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.margin
			),
			stackView.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			),
			stackView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.margin
			),
			stackView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height * 0.7) // HOTFIX hack, bottomsheet forced to 70% height.
		])
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The message
	var message: String? {
		didSet {
			guard let message = message else { return }

			let style = """
				body {
					 margin:0px;
				}
				 p {
					 font-family: -apple-system;
					 color: #383836;
					 font-size: 17px;
				}
			"""

			let html = """
				<html>
					<head>
						<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
						<style>
							\(style)
						</style>
					</head>
					<body>\(message)</body>
				</html>
			"""

			webView.loadHTMLString(html, baseURL: nil)
		}
	}

	var linkTapHandler: ((URL) -> Void)?

	func handleScreenCapture(shouldHide: Bool) {
		webView.isHidden = shouldHide
	}

}

extension InformationView: WKNavigationDelegate {

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {

		guard let url = navigationAction.request.url else {
			decisionHandler(.cancel)
			return
		}

		if url.absoluteURL.absoluteString == "about:blank" {
			decisionHandler(.allow)
		} else {
			linkTapHandler?(url)
			decisionHandler(.cancel)
		}
	}
}

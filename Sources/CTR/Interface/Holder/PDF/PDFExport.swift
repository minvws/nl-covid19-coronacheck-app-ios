/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import ReusableViews
import Resources
import Shared

import WebKit

class PDFExportViewModel {
	
	weak var coordinator: (OpenUrlProtocol & PDFExportCoordinatorDelegate)?
	
	var title = Observable<String>(value: L.holder_pdfExport_success_title())
	var message = Observable<String>(value: L.holder_pdfExport_success_message())
	var scriptUrl = Observable<URL?>(value: nil)
	
	init(coordinator: (OpenUrlProtocol & PDFExportCoordinatorDelegate)) {
	
		self.coordinator = coordinator
	}
	
	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url)
	}
	
	func viewDidAppear() {
		self.scriptUrl.value = Bundle.main.url(forResource: "index3", withExtension: "html")
	}
}

class PDFExportViewController: TraitWrappedGenericViewController<PDFExportView, PDFExportViewModel> {
	
	var webView: WKWebView?
//	= {
//
//		let webConfiguration = WKWebViewConfiguration()
//		webConfiguration.userContentController.add(self, name: "rolus")
//		let view = WKWebView(frame: .zero, configuration: webConfiguration)
//		return view
//	}()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		addBackButton(customAction: nil)
		
		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }
		sceneView.messageTextView.linkTouchedHandler = { [weak self] url in
			
			self?.viewModel.openUrl(url)
		}
		
//		let script =    """
//				var script = document.createElement('script');
//				script.src = './coronacheck-web-pdf-tools.js';
//				script.type = 'text/javascript';
//				document.getElementsByTagName('head')[0].appendChild(script);
//				"""
//		let userScript = WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true)
		
		let contentController = WKUserContentController()
//		contentController.addUserScript(userScript)
		contentController.add(self, name: "rolus")
		
		let webConfiguration = WKWebViewConfiguration()
		webConfiguration.userContentController = contentController
		webConfiguration.preferences.javaScriptEnabled = true
		webView = WKWebView(frame: .zero, configuration: webConfiguration)
		
		sceneView.stackView.addArrangedSubview(webView!)
		webView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
		
		viewModel.scriptUrl.observe { [weak self] url in
			guard let url else { return }
			self?.webView!.loadFileURL(url, allowingReadAccessTo: url)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		viewModel.viewDidAppear()
	}
}

extension PDFExportViewController: WKScriptMessageHandler {
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		
		if message.name == "rolus" {
			guard let dict = message.body as? [String: AnyObject] else {
				return
			}
			print(dict)
			if let dataString = dict["doc"] as? String {
				saveBase64StringToPDF(dataString)
			}
		}
	}
	
	func saveBase64StringToPDF(_ base64String: String) {
		
		let ccc = base64String.replacingOccurrences(of: "data:application/pdf;base64,", with: "")
		
		guard
			var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
			let convertedData = Data(base64Encoded: ccc)
		else {
			//handle error when getting documents URL
			return
		}
		
		//name your file however you prefer
		documentsURL.appendPathComponent("yourFileName.pdf")
		
		do {
			try convertedData.write(to: documentsURL)
		} catch {
			//handle write error here
		}
		
		//if you want to get a quick output of where your
		//file was saved from the simulator on your machine
		//just print the documentsURL and go there in Finder
		print(documentsURL)
	}
}

class PDFExportView: ScrolledStackView {
	
	/// The display constants
	private struct ViewTraits {
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
	}

	private let titleLabel: Label = {
		
		return Label(title3: nil, montserrat: true).multiline().header()
	}()
	
	let messageTextView: TextView = {
		
		return TextView()
	}()
	
//	let webView: WKWebView = {
//
//		let webConfiguration = WKWebViewConfiguration()
//		let view = WKWebView(frame: .zero, configuration: webConfiguration)
//		return view
//	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
		let linkTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: C.primaryBlue() as Any]
		messageTextView.linkTextAttributes = linkTextAttributes
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageTextView)
//		stackView.addArrangedSubview(webView)
	}
	
//	override func setupViewConstraints() {
//		super.setupViewConstraints()
//
//		webView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(
				text: message,
				style: NSAttributedString.HTMLStyle(
					font: Fonts.body,
					textColor: C.black()!,
					paragraphSpacing: 0
				)
			) {
				self.messageTextView.attributedText = $0
			}
		}
	}
}

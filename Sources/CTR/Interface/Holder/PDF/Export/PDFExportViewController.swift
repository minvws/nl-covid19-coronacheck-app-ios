/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Resources
import ReusableViews
import UIKit
import WebKit

class PDFExportViewController: TraitWrappedGenericViewController<PDFExportView, PDFExportViewModel> {
	
	static let postMessageIdentifier: String = "coronacheck"
	
	enum State {
		case loading
		case success
	}
	
	var webView: WKWebView?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		addBackButton(customAction: nil)
		setupTexts()
		setupObservers()
		setupActions()
	}
	
	private func setupTexts() {
		
		sceneView.message = L.holder_pdfExport_success_message()
		sceneView.cardView.title = L.holder_pdfExport_success_card_title()
		sceneView.cardView.message = L.holder_pdfExport_success_card_message()
		sceneView.cardView.actionButtonTitle = L.holder_pdfExport_success_card_action()
	}
	
	private func setupObservers() {
		
		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.state.observe { [weak self] state in
			switch state {
				case .loading:
					self?.sceneView.shouldShowLoadingSpinner = true
					self?.sceneView.messageTextView.isHidden = true
					self?.sceneView.cardView.isHidden = true
					self?.navigationItem.rightBarButtonItem = nil
				case .success:
					self?.sceneView.shouldShowLoadingSpinner = false
					self?.sceneView.messageTextView.isHidden = false
					self?.sceneView.cardView.isHidden = false
					self?.setupShareButton()
			}
		}
		viewModel.html.observe { [weak self] in
			guard let html = $0 else { return }
			self?.setupWebView(html: html)
		}
		
		viewModel.previewURL.observe { [weak self] in
			guard let url = $0 else { return }
			
			let dc = UIDocumentInteractionController(url: url)
			dc.delegate = self
			dc.presentPreview(animated: true)
		}
	}
	
	private func setupActions() {
		
		sceneView.cardView.actionButtonCommand = { [weak viewModel] in
			viewModel?.openPDF()
		}
		
		sceneView.messageTextView.linkTouchedHandler = { [weak self] url in
			self?.viewModel.openUrl(url)
		}
	}
	
	func setupShareButton() {
		
		if #available(iOS 13.0, *) {
			let config = UIBarButtonItem.Configuration(
				target: self,
				action: #selector(share),
				content: .image(UIImage(systemName: "square.and.arrow.up")),
				accessibilityIdentifier: "ShareButton",
				accessibilityLabel: "Share"
			)
			let button: UIBarButtonItem = .create(config)
			navigationItem.rightBarButtonItem = button
		}
	}
	
	@objc func share() {
		
		viewModel.sharePDF()
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
		webView?.loadHTMLString(html, baseURL: nil)
	}
}

// MARK: - WKScriptMessageHandler

extension PDFExportViewController: WKScriptMessageHandler {
	
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		
		viewModel.handleMessage(message: message)
	}
}

// MARK: - UIDocumentInteractionControllerDelegate

extension PDFExportViewController: UIDocumentInteractionControllerDelegate {
	
	func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
		
		return self
	}
	
	func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
		
		viewModel.userHasEndedPDFPreview()
	}
}

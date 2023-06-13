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

class PDFExportViewModel {
	
	weak var coordinator: (OpenUrlProtocol & PDFExportCoordinatorDelegate)?
	
	var title = Observable<String>(value: L.holder_pdfExport_success_title())
	var message = Observable<String>(value: L.holder_pdfExport_success_message())
	
	init(coordinator: (OpenUrlProtocol & PDFExportCoordinatorDelegate)) {
	
		self.coordinator = coordinator
	}
	
	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url)
	}
}

class PDFExportViewController: TraitWrappedGenericViewController<PDFExportView, PDFExportViewModel> {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		addBackButton(customAction: nil)
		
		viewModel.title.observe { [weak self] in self?.sceneView.title = $0 }
		viewModel.message.observe { [weak self] in self?.sceneView.message = $0 }
		
		sceneView.messageTextView.linkTouchedHandler = { [weak self] url in
			
			self?.viewModel.openUrl(url)
		}
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
	}
	
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

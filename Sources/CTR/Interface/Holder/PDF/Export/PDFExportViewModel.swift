/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckUI
import Transport
import WebKit

class PDFExportViewModel: NSObject {
	
	private let fileName = "CoronaCheck - International.pdf"
	
	private var hasGeneratedPDF = false
	
	weak var coordinator: (OpenUrlProtocol & PDFExportCoordinatorDelegate)?
	weak private var cryptoManager: CryptoManaging? = Current.cryptoManager
	
	var title = Observable<String>(value: L.holder_pdfExport_generating_title())
	var html = Observable<String?>(value: nil)
	var state = Observable<PDFExportViewController.State>(value: .loading)
	var previewURL = Observable<URL?>(value: nil)
	
	init(coordinator: (OpenUrlProtocol & PDFExportCoordinatorDelegate)) {
		
		super.init()
		self.coordinator = coordinator
	}
	
	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url)
	}
	
	func viewDidAppear() {
		
		do {
			let pdfTools = try getContent(filePath: Bundle.main.path(forResource: "web-pdf-tools", ofType: "js"))
			var localHTML = try getContent(filePath: Bundle.main.path(forResource: "printportal", ofType: "html"))
			
			guard let configData = Current.cryptoLibUtility.read(.remoteConfiguration) else {
				displayError(Error.failedToLoadFile)
				return
			}
			let config = String(decoding: configData, as: UTF8.self).replacingOccurrences(of: #"\"#, with: "")
			let dccs = try getPrintableDCCs()
			
			localHTML = localHTML.replacingOccurrences(of: "!!locale!!", with: "en")
			localHTML = localHTML.replacingOccurrences(of: "!!pdfTools!!", with: pdfTools)
			localHTML = localHTML.replacingOccurrences(of: "!!configJSON!!", with: config)
			localHTML = localHTML.replacingOccurrences(of: "!!dccJSON!!", with: dccs)
			
			html.value = localHTML
		} catch {
			displayError(error)
		}
	}
	
	private enum Error: Swift.Error {
		case wrongFilePath
		case failedToLoadFile
		case failedToCreatePDF
		case failedToSavePDF
		case noDCCsToExport
		case failedToEncode
	}
	
	func openPDF() {
		if let url = FileStorage().documentsURL {
			let fileUrl = url.appendingPathComponent(self.fileName, isDirectory: false)
			previewURL.value = fileUrl
		}
	}
	
	func sharePDF(sender: UIView?) {
		if let url = FileStorage().documentsURL {
			let fileUrl = url.appendingPathComponent(self.fileName, isDirectory: false)
			coordinator?.userWishesToShare(fileUrl, sender: sender)
		}
	}
}

// MARK: - Fetch Data

extension PDFExportViewModel {
	
	private func getContent(filePath: String?) throws -> String {
		
		guard let filePath else { throw Error.wrongFilePath}
		do {
			let content = try String(contentsOfFile: filePath)
			return content
		} catch {
			throw Error.failedToLoadFile
		}
	}
	
	private func getPrintableDCCs() throws -> String {
		
		let greenCards = Current.walletManager.listGreenCards().sorted { lhs, rhs in
			// Order by event date, oldest first.
			lhs.castOrigins()?.first?.eventDate ?? .distantPast < rhs.castOrigins()?.first?.eventDate ?? .distantPast
		}
		guard greenCards.isNotEmpty else {
			throw Error.noDCCsToExport
		}
		
		var euPrintAttributes = [EUPrintAttributes]()
		greenCards.forEach { greenCard in
			if let credential = getEuCredentialAttributes(greenCard),
			   let data = greenCard.getLatestInternationalCredential()?.data {
				let qrString = String(decoding: data, as: UTF8.self)
				
				euPrintAttributes.append(
					EUPrintAttributes(
						digitalCovidCertificate: credential.digitalCovidCertificate,
						expirationTime: Date(timeIntervalSince1970: credential.expirationTime),
						qr: qrString
					)
				)
			}
		}
		let printAttributes = PrintAttributes(european: euPrintAttributes)
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		do {
			let encoded = try encoder.encode(printAttributes)
			return String(decoding: encoded, as: UTF8.self)
		} catch {
			throw Error.failedToEncode
		}
	}
	
	private func getEuCredentialAttributes(_ greenCard: GreenCard) -> EuCredentialAttributes? {
		
		guard greenCard.getType() == GreenCardType.eu else { return nil }
		
		if let credentialData = greenCard.getLatestInternationalCredential()?.data,
		   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData) {
			return euCredentialAttributes
		}
		return nil
	}
}

// MARK: - Handle PDF

extension PDFExportViewModel {
	
	func handleMessage(message: WKScriptMessage) {
		
		guard !hasGeneratedPDF else { return }
		guard message.name == PDFExportViewController.postMessageIdentifier else { return }
		guard let dict = message.body as? [String: AnyObject] else { return }
		
		if let dataString = dict["doc"] as? String {
			
			switch saveBase64StringToPDF(dataString) {
				case .success:
					hasGeneratedPDF = true
					title.value = L.holder_pdfExport_success_title()
					state.value = .success
				case .failure(let error):
					displayError(error)
			}
		}
	}
	
	private func saveBase64StringToPDF(_ base64String: String) -> Result<Void, Error> {
		
		let withoutLeadingInfoBase64String = base64String.replacingOccurrences(of: "data:application/pdf;base64,", with: "")
		
		guard
			var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
			let convertedData = Data(base64Encoded: withoutLeadingInfoBase64String)
		else {
			return .failure(Error.failedToCreatePDF)
		}
		// File name
		documentsURL.appendPathComponent(self.fileName)
		
		do {
			try convertedData.write(to: documentsURL)
			// logDebug("PDFExport: Saved to \(documentsURL)")
			return .success(())
		} catch {
			return .failure(Error.failedToSavePDF)
		}
	}
}

// MARK: - Error Handling

extension PDFExportViewModel {
	
	private func displayError(_ error: Swift.Error) {
		
		let clientCode: ErrorCode.ClientCode
		switch error {
			case Error.wrongFilePath: clientCode = .wrongFilePath
			case Error.failedToLoadFile: clientCode = .failedToLoadFile
			case Error.failedToCreatePDF: clientCode = .failedToCreatePDF
			case Error.failedToSavePDF: clientCode = .failedToSavePDF
			case Error.noDCCsToExport: clientCode = .noDCC
			case Error.failedToEncode: clientCode = .failedToEncode
			default: clientCode = .unhandled
		}
		
		let errorCode = ErrorCode(flow: .pdfFlow, step: .createPDF, clientCode: clientCode)
		let content = Content(
			title: L.holderErrorstateTitle(),
			body: L.holder_pdfExport_error_body(Current.contactInformationProvider.phoneNumberLink, "\(errorCode)"),
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: { [weak self] in
				self?.coordinator?.exportFailed()
			}
		)
		coordinator?.displayError(content: content)
	}
}

extension ErrorCode.Flow {
	
	static let pdfFlow = ErrorCode.Flow(value: "15")
}

extension ErrorCode.Step {
	
	static let createPDF = ErrorCode.Step(value: "10")
}

extension ErrorCode.ClientCode {
	
	static let wrongFilePath = ErrorCode.ClientCode(value: "120")
	static let failedToLoadFile = ErrorCode.ClientCode(value: "121")
	static let failedToCreatePDF = ErrorCode.ClientCode(value: "122")
	static let failedToSavePDF = ErrorCode.ClientCode(value: "123")
	static let noDCC = ErrorCode.ClientCode(value: "124")
	static let failedToEncode = ErrorCode.ClientCode(value: "031")
}

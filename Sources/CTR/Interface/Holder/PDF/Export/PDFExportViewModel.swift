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

import Persistence
import Models
import Managers

import WebKit

class PDFExportViewModel {
	
	private let fileName = "CoronaCheck - International.pdf"
	
	weak var coordinator: (OpenUrlProtocol & PDFExportCoordinatorDelegate)?
	weak private var cryptoManager: CryptoManaging? = Current.cryptoManager
	
	var title = Observable<String>(value: L.holder_pdfExport_generating_title())
	var message = Observable<String>(value: L.holder_pdfExport_success_message())
	var html = Observable<String?>(value: nil)
	var state = Observable<PDFExportViewController.State>(value: .loading)
	
	init(coordinator: (OpenUrlProtocol & PDFExportCoordinatorDelegate)) {
	
		self.coordinator = coordinator
	}
	
	func openUrl(_ url: URL) {
		
		coordinator?.openUrl(url)
	}
	
	func viewDidAppear() {
		
		do {
			let pdfTools = try getContent(filePath: Bundle.main.path(forResource: "coronacheck-web-pdf-tools", ofType: "js"))
			var localHTML = try getContent(filePath: Bundle.main.path(forResource: "printportal", ofType: "html"))
			guard let configData = Current.cryptoLibUtility.read(.remoteConfiguration) else { return }
			let config = String(decoding: configData, as: UTF8.self).replacingOccurrences(of: #"\"#, with: "")
			let dccs = try getPrintableDCCs()
				
			localHTML = localHTML.replacingOccurrences(of: "!!pdfTools!!", with: pdfTools)
			localHTML = localHTML.replacingOccurrences(of: "!!configJSON!!", with: config)
			localHTML = localHTML.replacingOccurrences(of: "!!dccJSON!!", with: dccs)
			
			html.value = localHTML
		} catch {
			displayError(error)
		}
	}
	
	private func getContent(filePath: String?) throws -> String {
		
		guard let filePath else { throw Error.wrongFilePath}
			do {
				let content = try String(contentsOfFile: filePath)
				return content
			} catch {
				throw Error.cantloadFile
			}
	}
	
	private enum Error: Swift.Error {
		case wrongFilePath
		case cantloadFile
		case cantCreatePDF
		case cantSavePDF
	}
	
	private func getPrintableDCCs() throws -> String {
		
		var euPrintAttributes = [EUPrintAttributes]()
		let greenCards = Current.walletManager.listGreenCards()
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
		let encoded = try encoder.encode(printAttributes)
		return String(decoding: encoded, as: UTF8.self)
	}
	
	private func getEuCredentialAttributes(_ greenCard: GreenCard) -> EuCredentialAttributes? {
		
		guard greenCard.getType() == GreenCardType.eu else { return nil }
		
		if let credentialData = greenCard.getLatestInternationalCredential()?.data,
		   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData) {
			return euCredentialAttributes
		}
		return nil
	}
	
	func handleMessage(message: WKScriptMessage) {
		
		guard message.name == PDFExportViewController.postMessageIdentifier else { return }
		guard let dict = message.body as? [String: AnyObject] else { return }
		
		if let dataString = dict["doc"] as? String {
			
			switch saveBase64StringToPDF(dataString) {
				case .success:
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
			return .failure(Error.cantCreatePDF)
		}
		// File name
		documentsURL.appendPathComponent(self.fileName)
		
		do {
			try convertedData.write(to: documentsURL)
			logDebug("PDFExport: Saved to \(documentsURL)")
			return .success(())
		} catch {
			return .failure(Error.cantSavePDF)
		}
	}
	
	private func displayError(_ error: Swift.Error) {
		
		let content = Content(title: "Rolus")
		coordinator?.displayError(content: content)
	}
	
	func share() {
		if let url = FileStorage().documentsURL {
			let fileUrl = url.appendingPathComponent(self.fileName, isDirectory: false)
			coordinator?.userWishesToShare(fileUrl)
		}
	}
	
}

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
	
	weak var coordinator: (OpenUrlProtocol & PDFExportCoordinatorDelegate)?
	weak private var cryptoManager: CryptoManaging? = Current.cryptoManager
	
	var title = Observable<String>(value: L.holder_pdfExport_success_title())
	var message = Observable<String>(value: L.holder_pdfExport_success_message())
	var html = Observable<String?>(value: nil)
	
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

		}
	}
	
	private func getContent(filePath: String?) throws -> String {
		
		guard let filePath else { throw Error.wrongFilePath}
			do {
				let content = try String(contentsOfFile: filePath)
				print(content.prefix(100))
				return content
			} catch {
				print("file not found \(filePath)")
				throw Error.cantloadFile
			}
	}
	
	private enum Error: Swift.Error {
		case wrongFilePath
		case cantloadFile
	}
	
	private func getPrintableDCCs() throws -> String {
		
		var euPrintAttributes = [EUPrintAttributes]()
		let greenCards = Current.walletManager.listGreenCards()
		greenCards.forEach { greenCard in
			if let credential = getEuCredentialAttributes(greenCard) {
//				print("credentials: \(credential)")
				
				if let data = greenCard.getLatestInternationalCredential()?.data {
					let qrString = String(decoding: data, as: UTF8.self)
//					print("QR -> \(qrString)")
					
					euPrintAttributes.append(
						EUPrintAttributes(
							digitalCovidCertificate: credential.digitalCovidCertificate,
							expirationTime: Date(timeIntervalSince1970: credential.expirationTime),
							qr: qrString
						)
					)
				}
			}
		}
		let printAttributes = PrintAttributes(european: euPrintAttributes)
		
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let encoded = try encoder.encode(printAttributes)
		return String(decoding: encoded, as: UTF8.self)
	}
	
	func getEuCredentialAttributes(_ greenCard: GreenCard) -> EuCredentialAttributes? {
		
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
			saveBase64StringToPDF(dataString)
		}
	}
	
	func saveBase64StringToPDF(_ base64String: String) {
		
		let withoutLeadingInfoBase64String = base64String.replacingOccurrences(of: "data:application/pdf;base64,", with: "")
		
		guard
			var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
			let convertedData = Data(base64Encoded: withoutLeadingInfoBase64String)
		else {
			// handle error when getting documents URL
			return
		}
		// File name
		documentsURL.appendPathComponent("CoronaCheck - Internationaal.pdf")
		
		do {
			try convertedData.write(to: documentsURL)
		} catch {
			// handle write error here
		}
		
		// if you want to get a quick output of where your
		// file was saved from the simulator on your machine
		// just print the documentsURL and go there in Finder
		print(documentsURL)
	}
}

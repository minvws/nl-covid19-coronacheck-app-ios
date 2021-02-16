/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class CreateProofViewiewModel: Logging {

	var loggingCategory: String = "CreateProofViewiewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	weak var proofManager: ProofManaging?

	weak var cryptoManager: CryptoManaging?

	/// The network manager
	var networkManager: NetworkManaging?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: NSAttributedString?
	@Bindable private(set) var buttonTitle: String = .next
	@Bindable private(set) var showProgress: Bool = false

	/// DescriptionInitializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	///   - cryptoManager: the crypto manager
	///   - networkManager: the network manager
	init(
		coordinator: HolderCoordinatorDelegate,
		proofManager: ProofManaging,
		cryptoManager: CryptoManaging,
		networkManager: NetworkManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		self.cryptoManager = cryptoManager
		self.networkManager = networkManager

		self.title = .holderCreateProofTitle
		self.buttonTitle = .holderCreateProofAction

		createMessage()
		createProof()
	}

	/// Create the message
	func createMessage() {

		if let wrapper = proofManager?.getTestWrapper(),
		   let dateString = wrapper.result?.sampleDate,
		   let date = parseDateFormatter.date(from: dateString) {

			let printTime = printTimeFormatter.string(from: date)
			let printDate = printDateFormatter.string(from: date)
			let printOutput = "\(printDate) " + String.holderCreateProofAt + " \(printTime)"
			let messageString = String(format: .holderCreateProofText, printOutput)
			let attributedMessage = NSAttributedString(string: messageString)
			message = attributedMessage.bold([printOutput, .holderCreateProofBold], with: Theme.fonts.bodyBold)
		}
	}

	// Create the proof
	func createProof() {

		showProgress = true

		networkManager?.getNonce { [weak self] resultwrapper in

			switch resultwrapper {
				case let .success(envelope):

					self?.cryptoManager?.setNonce(envelope.nonce)
					self?.cryptoManager?.setStoken(envelope.stoken)
					self?.fetchTestProof()
				case let .failure(networkError):
					self?.showProgress = false

					self?.logError("Can't fetch the nonce: \(networkError.localizedDescription)")
			}
		}
	}

	/// Fetch the proof
	func fetchTestProof() {

		if let icm = cryptoManager?.generateCommitmentMessage(),
		   let icmDictionary = icm.convertToDictionary(),
		   let stoken = cryptoManager?.getStoken(),
		   let wrapper = proofManager?.getSignedWrapper() {

			let dictionary: [String: AnyObject] = [
				"test": generateString(object: wrapper) as AnyObject,
				"stoken": stoken as AnyObject,
				"icm": icmDictionary as AnyObject
			]

			networkManager?.fetchTestResultsWithISM(dictionary: dictionary) { [weak self] resultwrapper in

				switch resultwrapper {
					case let .success(data):
						self?.handleTestProofsResponse(data)
					case let .failure(networkError):
						self?.showProgress = false
						self?.logError("Can't fetch the ISM: \(networkError.localizedDescription)")
				}
			}
		}
	}

	private func handleTestProofsResponse(_ data: Data?) {

		if let unwrapped = data {

			logDebug("ISM Response: \(String(decoding: unwrapped, as: UTF8.self))")
		}
		showProgress = false
		cryptoManager?.setProofs(data)
		proofManager?.removeTestWrapper()
		if let message = cryptoManager?.generateQRmessage() {
			print("message: \(message)")
		}
	}

	func generateString<T>(object: T) -> String where T: Codable {

		if let data = try? JSONEncoder().encode(object),
		   let convertedToString = String(data: data, encoding: .utf8) {
			print("CTR: Converted to \(convertedToString)")
			return convertedToString
		}
		return ""
	}

	func buttonClick() {

		coordinator?.navigateBackToStart()
	}

	/// Formatter to parse
	private lazy var parseDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.calendar = .current
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		return dateFormatter
	}()

	/// Formatter to print date
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "d MMMM"
		return dateFormatter
	}()

	/// Formatter to print time
	private lazy var printTimeFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "HH:mm"
		return dateFormatter
	}()
}

/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

protocol GreenCardResponseParserDelegate: AnyObject {
	
	/// The GreenCardLoader was succesful
	func onSuccess(_ response: RemoteGreenCards.Response)
	
	/// There seems to be no internet connection
	func onNoInternet()
	
	/// The origins did not evaluate (mismatch state)
	func onDidNotEvaluate()
	
	/// There seems to be no signed events to be send
	func onNoEventsToBeSend()
	
	/// An error occured
	/// - Parameters:
	///   - title: the title of the error
	///   - message: the body of the error
	func onError(title: String, message: String)
	
	/// Get the flow for the error states
	/// - Returns: Flow.
	func getFlow() -> ErrorCode.Flow
}

class GreenCardResponseParser: Logging {
	
	weak private var delegate: GreenCardResponseParserDelegate?
	
	init(delegate: GreenCardResponseParserDelegate) {
		self.delegate = delegate
	}
	
	func handleResult(_ result: Result<RemoteGreenCards.Response, Error>) {
		
		switch result {
			case let .success(response):
				delegate?.onSuccess(response)

			case .failure(GreenCardLoader.Error.didNotEvaluate):
				delegate?.onDidNotEvaluate()

			case .failure(GreenCardLoader.Error.noEvents):
				delegate?.onNoEventsToBeSend()

			case .failure(GreenCardLoader.Error.failedToParsePrepareIssue):
				self.handleClientSideError(clientCode: .failedToParsePrepareIssue, for: .nonce)

			case .failure(GreenCardLoader.Error.preparingIssue(let serverError)):
				self.handleServerError(serverError, for: .nonce)

			case .failure(GreenCardLoader.Error.failedToGenerateCommitmentMessage):
				self.handleClientSideError(clientCode: .failedToGenerateCommitmentMessage, for: .nonce)

			case .failure(GreenCardLoader.Error.credentials(let serverError)):
				self.handleServerError(serverError, for: .signer)

			case .failure(GreenCardLoader.Error.failedToSaveGreenCards):
				self.handleClientSideError(clientCode: .failedToSaveGreenCards, for: .storingCredentials)

			case .failure(let error):
				self.logError("GreenCardResponseHelper - handleResult - unhandled: \(error)")
				self.handleClientSideError(clientCode: .unhandled, for: .signer)
		}
	}
	
	private func handleClientSideError(clientCode: ErrorCode.ClientCode, for step: ErrorCode.Step) {
		
		guard let flow = delegate?.getFlow() else { return }
		
		let errorCode = ErrorCode(flow: flow, step: step, clientCode: clientCode)
		displayClientErrorCode(errorCode)
	}
	
	private func handleServerError(_ serverError: ServerError, for step: ErrorCode.Step) {
		
		guard let flow = delegate?.getFlow() else { return }
		
		if case let ServerError.error(statusCode, serverResponse, error) = serverError {
			self.logDebug("GreenCardResponseParser = handleServerError \(serverError)")
			
			switch error {
				case .serverBusy:
					showServerBusy(ErrorCode(flow: flow, step: step, errorCode: "429"))
					
				case .serverUnreachableTimedOut, .serverUnreachableInvalidHost, .serverUnreachableConnectionLost:
					showServerUnreachable(ErrorCode(flow: flow, step: step, clientCode: error.getClientErrorCode() ?? .unhandled))
					
				case .noInternetConnection:
					delegate?.onNoInternet()
					
				case .responseCached, .redirection, .resourceNotFound, .serverError:
					// 304, 3xx, 4xx, 5xx
					let errorCode = ErrorCode(
						flow: flow,
						step: step,
						provider: nil,
						errorCode: "\(statusCode ?? 000)",
						detailedCode: serverResponse?.code
					)
					displayServerErrorCode(errorCode)
					
				case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize, .authenticationCancelled:
					// Client side
					let errorCode = ErrorCode(
						flow: flow,
						step: step,
						provider: nil,
						clientCode: error.getClientErrorCode() ?? .unhandled,
						detailedCode: serverResponse?.code
					)
					displayClientErrorCode(errorCode)
			}
		}
	}
	
	private func showServerUnreachable(_ errorCode: ErrorCode) {
		
		logDebug("GreenCardResponseParser - showServerUnreachable - errorCode: \(errorCode)")
		displayErrorCode(title: L.holderErrorstateTitle(), message: L.generalErrorServerUnreachableErrorCode("\(errorCode)"))
	}
	
	private func showServerBusy(_ errorCode: ErrorCode) {
		
		logDebug("GreenCardResponseParser - showServerBusy - errorCode: \(errorCode)")
		displayErrorCode(title: L.generalNetworkwasbusyTitle(), message: L.generalNetworkwasbusyErrorcode("\(errorCode)"))
	}
	
	private func displayClientErrorCode(_ errorCode: ErrorCode) {
		
		logDebug("GreenCardResponseParser - displayClientErrorCode - errorCode: \(errorCode)")
		displayErrorCode(title: L.holderErrorstateTitle(), message: L.holderErrorstateClientMessage("\(errorCode)"))
	}
	
	private func displayServerErrorCode(_ errorCode: ErrorCode) {
		
		logDebug("GreenCardResponseParser - displayServerErrorCode - errorCode: \(errorCode)")
		displayErrorCode(title: L.holderErrorstateTitle(), message: L.holderErrorstateServerMessage("\(errorCode)"))
	}
	
	private func displayErrorCode(title: String, message: String) {
		
		delegate?.onError(title: title, message: message)
	}
}

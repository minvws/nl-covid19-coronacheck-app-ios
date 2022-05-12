/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

enum GreenCardResponseError: Error {

	case noInternet
	case noSignedEvents
	case didNotEvaluate
	case customError(title: String, message: String)
}

class GreenCardResponseErrorParser: Logging {
	
	private var flow: ErrorCode.Flow
	
	init(flow: ErrorCode.Flow) {
		self.flow = flow
	}
	
	func parse(_ error: Error) -> GreenCardResponseError {
		
		switch error {
			case GreenCardLoader.Error.didNotEvaluate:
				return .didNotEvaluate
				
			case GreenCardLoader.Error.noSignedEvents:
				return .noSignedEvents
				
			case GreenCardLoader.Error.failedToParsePrepareIssue:
				return handleClientSideError(clientCode: .failedToParsePrepareIssue, for: .nonce)
				
			case GreenCardLoader.Error.preparingIssue(let serverError):
				return handleServerError(serverError, for: .nonce)
				
			case GreenCardLoader.Error.failedToGenerateCommitmentMessage:
				return handleClientSideError(clientCode: .failedToGenerateCommitmentMessage, for: .nonce)
				
			case GreenCardLoader.Error.credentials(let serverError):
				return self.handleServerError(serverError, for: .signer)
				
			case GreenCardLoader.Error.failedToSaveGreenCards:
				return handleClientSideError(clientCode: .failedToSaveGreenCards, for: .storingCredentials)
				
			default:
				self.logError("GreenCardResponseHelper - handleResult - unhandled: \(error)")
				return handleClientSideError(clientCode: .unhandled, for: .signer)
		}
	}
	
	private func handleClientSideError(clientCode: ErrorCode.ClientCode, for step: ErrorCode.Step) -> GreenCardResponseError {
		
		let errorCode = ErrorCode(flow: flow, step: step, clientCode: clientCode)
		return customErrorForClientErrorCode(errorCode)
	}
	
	private func handleServerError(_ serverError: ServerError, for step: ErrorCode.Step) -> GreenCardResponseError {
		
		switch serverError {
			case .error(let statusCode, let serverResponse, let error), .provider(_, let statusCode, let serverResponse, let error):
				self.logDebug("GreenCardResponseParser = handleServerError \(serverError)")
				
				switch error {
					case .serverBusy:
						return customErrorForServerBusy(ErrorCode(flow: flow, step: step, errorCode: "429"))
						
					case .serverUnreachableTimedOut, .serverUnreachableInvalidHost, .serverUnreachableConnectionLost:
						return customErrorForServerUnreachable(ErrorCode(flow: flow, step: step, clientCode: error.getClientErrorCode() ?? .unhandled))
						
					case .noInternetConnection:
						return .noInternet
						
					case .responseCached, .redirection, .resourceNotFound, .serverError:
						// 304, 3xx, 4xx, 5xx
						let errorCode = ErrorCode(
							flow: flow,
							step: step,
							provider: nil,
							errorCode: "\(statusCode ?? 000)",
							detailedCode: serverResponse?.code
						)
						return customErrorForServerErrorCode(errorCode)
						
					case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize, .authenticationCancelled:
						// Client side
						let errorCode = ErrorCode(
							flow: flow,
							step: step,
							provider: nil,
							clientCode: error.getClientErrorCode() ?? .unhandled,
							detailedCode: serverResponse?.code
						)
						return customErrorForClientErrorCode(errorCode)
				}
		}
	}
	
	private func customErrorForServerUnreachable(_ errorCode: ErrorCode) -> GreenCardResponseError {
		
		logDebug("GreenCardResponseParser - showServerUnreachable - errorCode: \(errorCode)")
		return GreenCardResponseError.customError(
			title: L.holderErrorstateTitle(),
			message: L.generalErrorServerUnreachableErrorCode("\(errorCode)")
		)
	}
	
	private func customErrorForServerBusy(_ errorCode: ErrorCode) -> GreenCardResponseError {
		
		logDebug("GreenCardResponseParser - showServerBusy - errorCode: \(errorCode)")
		return GreenCardResponseError.customError(
			title: L.generalNetworkwasbusyTitle(),
			message: L.generalNetworkwasbusyErrorcode("\(errorCode)")
		)
	}
	
	private func customErrorForClientErrorCode(_ errorCode: ErrorCode) -> GreenCardResponseError {
		
		logDebug("GreenCardResponseParser - displayClientErrorCode - errorCode: \(errorCode)")
		return GreenCardResponseError.customError(
			title: L.holderErrorstateTitle(),
			message: L.holderErrorstateClientMessage("\(errorCode)")
		)
	}
	
	private func customErrorForServerErrorCode(_ errorCode: ErrorCode) -> GreenCardResponseError {
		
		logDebug("GreenCardResponseParser - displayServerErrorCode - errorCode: \(errorCode)")
		return GreenCardResponseError.customError(
			title: L.holderErrorstateTitle(),
			message: L.holderErrorstateServerMessage("\(errorCode)")
		)
	}
}

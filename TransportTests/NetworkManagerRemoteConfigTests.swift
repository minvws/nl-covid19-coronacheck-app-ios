/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import Transport
import XCTest
import Nimble
import OHHTTPStubs
import OHHTTPStubsSwift

class NetworkManagerRemoteConfigTests: XCTestCase {
	
	private var sut: NetworkManager!
	private let path = "/v8/holder/config"
	
	override func setUp() {
		
		super.setUp()
		sut = NetworkManager(configuration: NetworkConfiguration.development, dataTLSCertificates: { [] })
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	// MARK: Network errors

	func test_getRemoteConfiguration_noInternet() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .noInternetConnection)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_serverBusy() {

		// Given
		stub(condition: isPath(path)) { _ in
			return HTTPStubsResponse(data: Data(), statusCode: 429, headers: nil)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 429, response: nil, error: .serverBusy)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_timeOut() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.timedOut.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_invalidHost() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cannotFindHost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableInvalidHost)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_networkConnectionLost() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.networkConnectionLost.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableConnectionLost)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_cancelled() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.cancelled.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .authenticationCancelled)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_unknownError() {

		// Given
		stub(condition: isPath(path)) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.unknown.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidResponse)
				done()
			}
		}
	}

	// MARK: Signed Response Checks

	func test_getRemoteConfiguration_unsignedResponse() {

		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"iosMinimumVersion": "3.0.1"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_signedResponse_signatureNotBase64() {

		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "test",
					"signature": "test\n"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_signedResponse_payloadNotBase64() {

		// Given
		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "test\n",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_signedResponse_invalidSignature() {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = false
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			dataTLSCertificates: { [] }
		)

		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "test",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: nil, response: nil, error: .invalidSignature)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_signedResponse_invalidContent() {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			dataTLSCertificates: { [] }
		)

		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "test",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isFailure) == true
				expect(result.failureError) == ServerError.error(statusCode: 200, response: nil, error: .cannotDeserialize)
				done()
			}
		}
	}

	func test_getRemoteConfiguration_validContent() {

		// Given
		let signatureValidationFactorySpy = SignatureValidationFactorySpy()
		let signatureValidationSpy = SignatureValidationSpy()
		signatureValidationSpy.stubbedValidateResult = true
		signatureValidationFactorySpy.stubbedGetSignatureValidatorResult = signatureValidationSpy
		sut = NetworkManager(
			configuration: NetworkConfiguration.development,
			signatureValidationFactory: signatureValidationFactorySpy,
			dataTLSCertificates: { [] }
		)

		stub(condition: isPath(path)) { _ in
			// Return valid tokens
			return HTTPStubsResponse(
				jsonObject: [
					"payload": "eyJhbmRyb2lkTWluaW11bVZlcnNpb24iOjM3MzQsImFuZHJvaWRSZWNvbW1lbmRlZFZlcnNpb24iOjM3MzQsImFuZHJvaWRNaW5pbXVtVmVyc2lvbk1lc3NhZ2UiOiJPbSBkZSBhcHAgdGUgZ2VicnVpa2VuIGhlYiBqZSBkZSBsYWF0c3RlIHZlcnNpZSB1aXQgZGUgc3RvcmUgbm9kaWcuIiwicGxheVN0b3JlVVJMIjoiaHR0cHM6Ly9wbGF5Lmdvb2dsZS5jb20vc3RvcmUvYXBwcy9kZXRhaWxzP2lkPW5sLnJpamtzb3ZlcmhlaWQuY3RyLmhvbGRlciIsImlvc01pbmltdW1WZXJzaW9uIjoiMy4wLjEiLCJpb3NSZWNvbW1lbmRlZFZlcnNpb24iOiIzLjAuMSIsImlvc01pbmltdW1WZXJzaW9uTWVzc2FnZSI6Ik9tIGRlIGFwcCB0ZSBnZWJydWlrZW4gaGViIGplIGRlIGxhYXRzdGUgdmVyc2llIHVpdCBkZSBzdG9yZSBub2RpZy4iLCJpb3NBcHBTdG9yZVVSTCI6Imh0dHBzOi8vYXBwcy5hcHBsZS5jb20vbmwvYXBwL2Nvcm9uYWNoZWNrL2lkMTU0ODI2OTg3MCIsImFwcERlYWN0aXZhdGVkIjpmYWxzZSwibWlqbkNuRW5hYmxlZCI6dHJ1ZSwiY29uZmlnVFRMIjozMDAsImNvbmZpZ01pbmltdW1JbnRlcnZhbFNlY29uZHMiOjYwLCJjb25maWdBbG1vc3RPdXRPZkRhdGVXYXJuaW5nU2Vjb25kcyI6MjQwLCJ1cGdyYWRlUmVjb21tZW5kYXRpb25JbnRlcnZhbCI6MjQsIm1heFZhbGlkaXR5SG91cnMiOjI0LCJpbmZvcm1hdGlvblVSTCI6Imh0dHBzOi8vY29yb25hY2hlY2submwiLCJhbmRyb2lkRW5hYmxlVmVyaWZpY2F0aW9uUG9saWN5VmVyc2lvbiI6MCwiaU9TRW5hYmxlVmVyaWZpY2F0aW9uUG9saWN5VmVyc2lvbiI6IjAiLCJyZXF1aXJlVXBkYXRlQmVmb3JlIjoxNjIwNzgxMTgxLCJldUxhdW5jaERhdGUiOiIyMDIxLTA2LTEwVDEzOjA1OjAwWiIsInJlY292ZXJ5R3JlZW5jYXJkUmV2aXNlZFZhbGlkaXR5TGF1bmNoRGF0ZSI6IjIwMjEtMTEtMDhUMjM6MDA6MDBaIiwidGVtcG9yYXJpbHlEaXNhYmxlZCI6ZmFsc2UsInZhY2NpbmF0aW9uQXNzZXNzbWVudEV2ZW50VmFsaWRpdHlEYXlzIjoxNCwidmlzaXRvclBhc3NFbmFibGVkIjp0cnVlLCJzaG93TmV3VmFsaWRpdHlJbmZvQ2FyZCI6dHJ1ZSwiZ2dkRW5hYmxlZCI6dHJ1ZSwidmFjY2luYXRpb25FdmVudFZhbGlkaXR5IjoxNDYwMCwidmFjY2luYXRpb25FdmVudFZhbGlkaXR5RGF5cyI6NzMwLCJyZWNvdmVyeUV2ZW50VmFsaWRpdHkiOjg3NjAsInJlY292ZXJ5RXZlbnRWYWxpZGl0eURheXMiOjM2NSwicmVjb3ZlcnlFeHBpcmF0aW9uRGF5cyI6MTgwLCJ0ZXN0RXZlbnRWYWxpZGl0eSI6MzM2LCJ0ZXN0RXZlbnRWYWxpZGl0eUhvdXJzIjozMzYsImRvbWVzdGljQ3JlZGVudGlhbFZhbGlkaXR5IjoyNCwiY3JlZGVudGlhbFJlbmV3YWxEYXlzIjo0LCJjbG9ja0RldmlhdGlvblRocmVzaG9sZFNlY29uZHMiOjMwLCJkb21lc3RpY1FSUmVmcmVzaFNlY29uZHMiOjMwLCJpbnRlcm5hdGlvbmFsUVJSZWxldmFuY3lEYXlzIjoyOCwibHVobkNoZWNrRW5hYmxlZCI6dHJ1ZSwicHJvb2ZTZXJpYWxpemF0aW9uVmVyc2lvbiI6IjIiLCJwb3NpdGl2ZVRlc3RWaWFUb2tlbkludG9Gb3JjZURhdGUiOiIyMDIyLTA0LTAxVDAwOjAwOjAwWiIsImJhY2tlbmRUTFNDZXJ0aWZpY2F0ZXMiOlsidGVzdCJdLCJkaXNjbG9zdXJlUG9saWN5IjpbXSwiZGlzY2xvc3VyZVBvbGljaWVzIjpbXSwiZXVUZXN0UmVzdWx0cyI6W3siY29kZSI6IjI2MDQxNTAwMCIsIm5hbWUiOiJOZWdhdGllZiAoZ2VlbiBjb3JvbmEpIn0seyJjb2RlIjoiMjYwMzczMDAxIiwibmFtZSI6IlBvc2l0aWVmIChjb3JvbmEpIn1dLCJocGtDb2RlcyI6W3siY29kZSI6IjI5MjQ1MjgiLCJuYW1lIjoiUGZpemVyIChDb21pcm5hdHkpIiwidnAiOiIxMTE5MzQ5MDA3IiwibXAiOiJFVS8xLzIwLzE1MjgiLCJtYSI6Ik9SRy0xMDAwMzAyMTUifSx7ImNvZGUiOiIyOTI0NTM2IiwibmFtZSI6Ik1vZGVybmEgKENPVklELTE5IFZhY2NpbiBNb2Rlcm5hIDAsNTBNTCkiLCJ2cCI6IjExMTkzNDkwMDciLCJtcCI6IkVVLzEvMjAvMTUwNyIsIm1hIjoiT1JHLTEwMDAzMTE4NCJ9LHsiY29kZSI6IjI5MjU1MDgiLCJuYW1lIjoiQXN0cmFaZW5lY2EgKFZheHpldnJpYSkiLCJ2cCI6IkowN0JYMDMiLCJtcCI6IkVVLzEvMjEvMTUyOSIsIm1hIjoiT1JHLTEwMDAwMTY5OSJ9LHsiY29kZSI6IjI5MzQ3MDEiLCJuYW1lIjoiSmFuc3NlbiAoQ09WSUQtMTkgVmFjY2luIEphbnNzZW4pIiwidnAiOiJKMDdCWDAzIiwibXAiOiJFVS8xLzIwLzE1MjUiLCJtYSI6Ik9SRy0xMDAwMDE0MTcifSx7ImNvZGUiOiI5MzU0MDEwMSIsIm5hbWUiOiJDT1ZJRC0xOSBUUklBTCBWQUNDSU4gQUtTLTQ1MiBJTkpWTFNUIDAsNU1MIFNDIFZCIiwidnAiOiJKMDdCWDAzIiwibXAiOiJOTDpBS1MtNDUyLVZCIiwibWEiOiJOTDpBS1MifSx7ImNvZGUiOiI5MzU1MDEwMSIsIm5hbWUiOiJDT1ZJRC0xOSBUUklBTCBWQUNDSU4gQUtTLTQ1MiBJTkpWTFNUIDAsNU1MIFNDIEhCIiwidnAiOiJKMDdCWDAzIiwibXAiOiJOTDpBS1MtNDUyLUhCIiwibWEiOiJOTDpBS1MifSx7ImNvZGUiOiIyOTc4NjM2IiwibmFtZSI6Ik1vZGVybmEgKENPVklELTE5IFZhY2NpbiBNb2Rlcm5hIDAsMjVNTCkiLCJ2cCI6IjExMTkzNDkwMDciLCJtcCI6IkVVLzEvMjAvMTUwNyIsIm1hIjoiT1JHLTEwMDAzMTE4NCJ9LHsiY29kZSI6IjI5ODQ5MTEiLCJuYW1lIjoiQ09WSUQtMTkgVkFDQ0lOIFBGSVpFUiBJTkpWTFNUIDAsMk1MIiwidnAiOiIxMTE5MzQ5MDA3IiwibXAiOiJFVS8xLzIwLzE1MjgiLCJtYSI6Ik9SRy0xMDAwMzAyMTUifSx7ImNvZGUiOiI5MzU1MDEwMiIsIm5hbWUiOiJDT1ZJRC0xOSBUUklBTCBWQUNDSU4gSkFOU1NFTiBJTkpWTFNUIDAsNU1MIEhCIiwidnAiOiJKMDdCWDAzIiwibXAiOiJOTDpBS1MtNDUyLUhCIiwibWEiOiJOTDpBS1MifSx7ImNvZGUiOiI5MzU1MDEwMyIsIm5hbWUiOiJDT1ZJRC0xOSBUUklBTCBWQUNDSU4gVkFMTkVWQSBJTkpWTFNUIDAsNU1MIEhCIiwidnAiOiJKMDdCWDAzIiwibXAiOiJWTEEyMDAxIiwibWEiOiJPUkctMTAwMDM2NDIyIn0seyJjb2RlIjoiMjkzOTI3NCIsIm5hbWUiOiJDT1ZJRC0xOSBWQUNDSU4gTk9WQVZBWCBJTkpWTFNUIDAsNU1MIiwidnAiOiJKMDdCWDAzIiwibXAiOiJFVS8xLzIxLzE2MTgiLCJtYSI6Ik9SRy0xMDAwMzIwMjAifV0sImV1QnJhbmRzIjpbeyJjb2RlIjoiRVUvMS8yMC8xNTI4IiwibmFtZSI6IlBmaXplciAoQ29taXJuYXR5KSJ9LHsiY29kZSI6IkVVLzEvMjAvMTUwNyIsIm5hbWUiOiJNb2Rlcm5hIChTcGlrZXZheCkifSx7ImNvZGUiOiJFVS8xLzIxLzE1MjkiLCJuYW1lIjoiQXN0cmFaZW5lY2EgKFZheHpldnJpYSkifSx7ImNvZGUiOiJFVS8xLzIwLzE1MjUiLCJuYW1lIjoiSmFuc3NlbiAoQ09WSUQtMTkgVmFjY2luIEphbnNzZW4pIn0seyJjb2RlIjoiQ1ZuQ29WIiwibmFtZSI6IkNWbkNvViJ9LHsiY29kZSI6Ik5WWC1Db1YyMzczIiwibmFtZSI6Ik51dmF4b3ZpZCAvIENvdm92YXggKE5vdmF2YXgpIn0seyJjb2RlIjoiU3B1dG5pay1WIiwibmFtZSI6IlNwdXRuaWstViJ9LHsiY29kZSI6IkNvbnZpZGVjaWEiLCJuYW1lIjoiQ29udmlkZWNpYSJ9LHsiY29kZSI6IkVwaVZhY0Nvcm9uYSIsIm5hbWUiOiJFcGlWYWNDb3JvbmEifSx7ImNvZGUiOiJCQklCUC1Db3JWIiwibmFtZSI6IkJCSUJQLUNvclYifSx7ImNvZGUiOiJJbmFjdGl2YXRlZC1TQVJTLUNvVi0yLVZlcm8tQ2VsbCIsIm5hbWUiOiJJbmFjdGl2YXRlZCBTQVJTLUNvVi0yIChWZXJvIENlbGwpIChkZXByZWNhdGVkKSJ9LHsiY29kZSI6IkNvcm9uYVZhYyIsIm5hbWUiOiJDb3JvbmFWYWMifSx7ImNvZGUiOiJDb3ZheGluIiwibmFtZSI6IkNvdmF4aW4ifSx7ImNvZGUiOiJDb3Zpc2hpZWxkIiwibmFtZSI6IkNvdmlzaGllbGQifSx7ImNvZGUiOiJDb3ZpZC0xOS1yZWNvbWJpbmFudCIsIm5hbWUiOiJDb3ZpZC0xOSAocmVjb21iaW5hbnQpIn0seyJjb2RlIjoiUi1DT1ZJIiwibmFtZSI6IlItQ09WSSJ9LHsiY29kZSI6IkNvdmlWYWMiLCJuYW1lIjoiQ292aVZhYyJ9LHsiY29kZSI6IlNwdXRuaWstTGlnaHQiLCJuYW1lIjoiU3B1dG5payBMaWdodCJ9LHsiY29kZSI6IkhheWF0LVZheCIsIm5hbWUiOiJIYXlhdC1WYXgifSx7ImNvZGUiOiJBYmRhbGEiLCJuYW1lIjoiQWJkYWxhIn0seyJjb2RlIjoiV0lCUC1Db3JWIiwibmFtZSI6IldJQlAtQ29yViJ9LHsiY29kZSI6Ik1WQy1DT1YxOTAxIiwibmFtZSI6Ik1WQyBDT1ZJRC0xOSB2YWNjaW5lIn0seyJjb2RlIjoiRVUvMS8yMS8xNjE4IiwibmFtZSI6Ik51dmF4b3ZpZCAvIENvdm92YXggKE5vdmF2YXgpIn0seyJjb2RlIjoiQ292b3ZheCIsIm5hbWUiOiJDb3ZvdmF4In0seyJjb2RlIjoiVmlkcHJldnR5biIsIm5hbWUiOiJWaWRwcmV2dHluIn0seyJjb2RlIjoiVkxBMjAwMSIsIm5hbWUiOiJWTEEyMDAxIn0seyJjb2RlIjoiRXBpVmFjQ29yb25hLU4iLCJuYW1lIjoiRXBpVmFjQ29yb25hLU4ifSx7ImNvZGUiOiJTcHV0bmlrLU0iLCJuYW1lIjoiU3B1dG5payBNIn0seyJjb2RlIjoiQ292aWQtMTktYWRzb3J2aWRhLWluYXRpdmFkYSIsIm5hbWUiOiJWYWNpbmEgYWRzb3J2aWRhIGNvdmlkLTE5IChpbmF0aXZhZGEpIn0seyJjb2RlIjoiTlZTSS0wNi0wOCIsIm5hbWUiOiJOVlNJLTA2LTA4In0seyJjb2RlIjoiWVMtU0MyLTAxMCIsIm5hbWUiOiJZUy1TQzItMDEwIn0seyJjb2RlIjoiU0NUVjAxQyIsIm5hbWUiOiJTQ1RWMDFDIn0seyJjb2RlIjoiQ292aWZlbnoiLCJuYW1lIjoiQ292aWZlbnoifSx7ImNvZGUiOiJBWkQyODE2IiwibmFtZSI6IkFaRDI4MTYifSx7ImNvZGUiOiJOTDpBS1MtNDUyLVZCIiwibmFtZSI6IkFLUy00NTIgKFZCKSJ9LHsiY29kZSI6Ik5MOkFLUy00NTItSEIiLCJuYW1lIjoiQUtTLTQ1MiAoSEIpIn1dLCJubFRlc3RUeXBlcyI6W3siY29kZSI6InBjciIsIm5hbWUiOiJQQ1IgVGVzdCJ9LHsiY29kZSI6InBjci1sYW1wIiwibmFtZSI6IlBDUiBUZXN0IChMQU1QKSJ9LHsiY29kZSI6ImFudGlnZW4iLCJuYW1lIjoiQW50aWdlbiBUZXN0In0seyJjb2RlIjoiYnJlYXRoIiwibmFtZSI6IkJyZWF0aCBUZXN0In1dLCJldVZhY2NpbmF0aW9ucyI6W3siY29kZSI6IjExMTkzNDkwMDciLCJuYW1lIjoiU0FSUy1Db1YtMiBtUk5BIHZhY2NpbmUifSx7ImNvZGUiOiIxMTE5MzA1MDA1IiwibmFtZSI6IlNBUlMtQ29WLTIgYW50aWdlbiB2YWNjaW5lIn0seyJjb2RlIjoiSjA3QlgwMyIsIm5hbWUiOiJjb3ZpZC0xOSB2YWNjaW5lcyJ9LHsiY29kZSI6IjExNjI2NDMwMDEiLCJuYW1lIjoiU0FSUy1Db1YtMiByZWNvbWJpbmFudCBzcGlrZSBwcm90ZWluIGFudGlnZW4gdmFjY2luZSJ9LHsiY29kZSI6IjExNTcwMjQwMDYiLCJuYW1lIjoiSW5hY3RpdmF0ZWQgd2hvbGUgU0FSUy1Db1YtMiBhbnRpZ2VuIHZhY2NpbmUifSx7ImNvZGUiOiIyOTA2MTAwMDA4NzEwMyIsIm5hbWUiOiJDT1ZJRC0xOSBub24tcmVwbGljYXRpbmcgdmlyYWwgdmVjdG9yIHZhY2NpbmUifV0sImV1TWFudWZhY3R1cmVycyI6W3siY29kZSI6Ik5MOkFLUyIsIm5hbWUiOiJOTDpBS1MifV0sImV1VGVzdFR5cGVzIjpbeyJjb2RlIjoiTFA2NDY0LTQiLCJuYW1lIjoiUENSIChOQUFUKSJ9LHsiY29kZSI6IkxQMjE3MTk4LTMiLCJuYW1lIjoiU25lbHRlc3QgKFJBVCkifSx7ImNvZGUiOiJOTDpCUkVBVEgiLCJuYW1lIjoiQnJlYXRob21peCwgU3Bpcm9ub3NlIn0seyJjb2RlIjoiTkw6QUdPQiIsIm5hbWUiOiJPbmJla2VuZCAvIFVua25vd24gKGJlaGFuZGVsZCBhbHMgYW50aWdlZW4pIn1dLCJldVRlc3RNYW51ZmFjdHVyZXJzIjpbeyJjb2RlIjoiTkw6VldTIiwibmFtZSI6IlZXUyBBcHByb3ZlZCJ9LHsiY29kZSI6Ik5MOkJNU04iLCJuYW1lIjoiVldTIEFwcHJvdmVkIEJNU04ifSx7ImNvZGUiOiJOTDpVTktOT1dOIiwibmFtZSI6IlVua25vd24ifV0sImV1VGVzdE5hbWVzIjpbeyJjb2RlIjoiTkw6VldTIiwibmFtZSI6IlZXUyBBcHByb3ZlZCJ9LHsiY29kZSI6Ik5MOkJNU04iLCJuYW1lIjoiVldTIEFwcHJvdmVkIEJNU04ifSx7ImNvZGUiOiJOTDpVTktOT1dOIiwibmFtZSI6IlVua25vd24ifV0sInByb3ZpZGVySWRlbnRpZmllcnMiOlt7Im5hbWUiOiJNVldTLVRFU1QiLCJjb2RlIjoiWlpaIn0seyJuYW1lIjoiUklWTSIsImNvZGUiOiJSVlYifSx7Im5hbWUiOiJHR0QiLCJjb2RlIjoiR0dEIn0seyJuYW1lIjoiWktWSSIsImNvZGUiOiJaS1YifV0sInVuaXZlcnNhbExpbmtEb21haW5zIjpbeyJ1cmwiOiJ3ZWIuYWNjLmNvcm9uYWNoZWNrLm5sIiwibmFtZSI6IkNvcm9uYUNoZWNrIGFwcCJ9XX0=",
					"signature": "test"
				],
				statusCode: 200,
				headers: nil
			)
		}

		// When
		waitUntil { done in
			self.sut.getRemoteConfiguration { result in

				// Then
				expect(result.isSuccess) == true
				expect(result.successValue?.0 is RemoteConfiguration) == true
				expect(result.successValue?.0.configTTL) == 300
				expect(result.successValue?.0.isGGDEnabled) == true
				expect(result.successValue?.0.configAlmostOutOfDateWarningSeconds) == 240
				expect(result.successValue?.0.disclosurePolicies).to(beEmpty())
				expect(result.successValue?.0.hpkCodes).to(haveCount(11))
				done()
			}
		}
	}
}

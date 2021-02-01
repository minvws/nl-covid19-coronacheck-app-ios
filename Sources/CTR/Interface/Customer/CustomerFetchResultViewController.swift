/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Sodium
import AppAuth

class FetchResultViewModel: Logging {

	var loggingCategory: String = "FetchResultViewModel"

	/// Configuration
	var configuration: ConfigurationDigidProtocol = Configuration()

	/// The open id client
	var openIdClient: OpenIdClientProtocol

	/// The API Client
	var apiClient: ApiClientProtocol = ApiClient()

	/// The crypto manager
	var cryptoManager: CryptoManagerProtocol = CryptoManager()

	/// The date formatter for the timestamps
	lazy var dateFormatter: DateFormatter = {

		let isoFormatter = DateFormatter()
		isoFormatter.dateFormat = "dd MMM YYYY - HH:mm"
		return isoFormatter
	}()

	/// Coordination Delegate
	weak var coordinator: CustomerCoordinatorDelegate?

	/// The user identifier
	var userIdentifier: String?

	weak var presentingViewController: UIViewController?

	// MARK: - Bindable properties

	@Bindable private(set) var primaryButtonTitle: String
	@Bindable private(set) var secondaryButtonTitle: String
	@Bindable private(set) var tertiaryButtonTitle: String?
	@Bindable private(set) var message: String = ""

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - userIdentifier: the user identifier
	init(
		coordinator: CustomerCoordinatorDelegate,
		openIdClient: OpenIdClientProtocol,
		userIdentifier: String?) {

		self.coordinator = coordinator
		primaryButtonTitle = "Login met Digid (Fake)"
		secondaryButtonTitle = "Login met Digid"
		self.userIdentifier = userIdentifier
		self.openIdClient = openIdClient
	}

	/// User tapped on the primary button
	func primaryButtonTapped() {

		fetchFakeTestResults()
	}

	/// User tapped on the second button
	func secondaryButtonTapped(_ viewController: UIViewController) {

		self.presentingViewController = viewController
		fetchNonce()
	}

	func getAccessToken() {

		guard let viewController = presentingViewController else {
			message = "Can't present login"
			return
		}

		openIdClient.requestAccessToken(
			presenter: viewController) { [weak self] accessToken in

			self?.message = "Access token: \(accessToken ?? "nil")"
			if let token = accessToken {
				self?.handleAccessToken(token)
			}
		} onError: { [weak self] error in
			self?.message = "Authorization error: \(error?.localizedDescription ?? "Unknown error")"
		}
	}

	/// Fetch a nonce from the server
	func fetchNonce() {
		apiClient.getNonce { [weak self] envelope in

			if let envelope = envelope {
				self?.cryptoManager.setNonce(envelope.nonce)
				self?.cryptoManager.setStoken(envelope.stoken)
				self?.cryptoManager.debug()
				self?.getAccessToken()
			} else {
				self?.message = "Can't connect"
			}
		}
	}

	func getTestResults() {
		//		apiClient.getTestResultsWithToken(token: accessToken) { [weak self] envelope in
		//
		//			self?.handleResponse(envelope)
		//		}
	}

	/// Post the access token
	/// - Parameter accessToken: the access token
	func handleAccessToken(_ accessToken: String) {

		if let icm = cryptoManager.generateCommitment(), let stoken = cryptoManager.getStoken() {
			self.logDebug("Woot Woot")

			apiClient.getTestResultsWithISM(accessToken: accessToken, stoken: stoken, issuerCommitmentMessage: icm) { (result) in
//				self.handleResponse(result)

				self.logDebug("ISM Response: \(String(describing: result))")

			}
		}
	}

	private func handleResponse(_ envelope: TestResultEnvelope?) {

		coordinator?.setTestResultEnvelope(envelope)
		logDebug("handleResponse: \(String(describing: envelope))")

		if let envelope = envelope {
			for result in envelope.testResults {

				var type = ""
				if let types = envelope.types {
					for candidate in types where result.testType == candidate.identifier {
						type = candidate.name
					}
				}

				let date = Date(timeIntervalSince1970: TimeInterval(result.dateTaken))
				message += "Test (\(type)) op \(dateFormatter.string(from: date)): \(result.result == 0 ? "NEG" : "POS")\n"
			}
		}
		// Show the button
		tertiaryButtonTitle = "Genereer toegangsbewijs"
	}

	/// User tapped on the third button
	func tertiaryButtonTapped() {

		coordinator?.navigateToCustomerQR()
	}

	/// Fetch some test results from the API
	func fetchFakeTestResults() {

//		guard let identifier = userIdentifier else {
//			return
//		}
//
//		message = ""

//		ApiClient().getTestResults(identifier: identifier) { [weak self] envelope in
//
//			self?.handleResponse(envelope)
//		}
	}
}

class CustomerFetchResultViewController: BaseViewController {

	private let viewModel: FetchResultViewModel

	let sceneView = MainView()

	init(viewModel: FetchResultViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		// Do any additional setup after loading the view.
		title = "Holder Fetch Result"

		viewModel.$primaryButtonTitle.binding = {

			self.sceneView.primaryTitle = $0
		}
		viewModel.$secondaryButtonTitle.binding = {

			self.sceneView.secondaryTitle = $0
		}
		viewModel.$tertiaryButtonTitle.binding = {

			self.sceneView.tertiaryTitle = $0 ?? ""
		}
		viewModel.$message.binding = {

			self.sceneView.message = $0
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in

			self?.viewModel.primaryButtonTapped()
		}

		sceneView.secondaryButtonTappedCommand = { [weak self] in

			guard let strongSelf = self else {
				return
			}
			strongSelf.viewModel.secondaryButtonTapped(strongSelf)
		}

		sceneView.tertiaryButtonTappedCommand = { [weak self] in

			self?.viewModel.tertiaryButtonTapped()
		}
	}
}

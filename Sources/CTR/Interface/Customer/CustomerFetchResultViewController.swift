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

		openIdClient.requestAccessToken(
			presenter: viewController) { accessToken in

			self.message = "Access token: \(accessToken ?? "nil")"
			if let token = accessToken {
				self.handleAccessToken(token)
			}
		} onError: { error in
			self.message = "Authorization error: \(error?.localizedDescription ?? "Unknown error")"
		}
	}

	/// Post the access token
	/// - Parameter accessToken: the access token
	func handleAccessToken(_ accessToken: String) {

//		apiClient.postAuthorizationToken(accessToken) { success in
//			self.message += "\n delivered to API \(success)"
//		}

		apiClient.getTestResultsWithToken(token: accessToken) { [weak self] envelope in

			self?.handleResponse(envelope)
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

		guard let identifier = userIdentifier else {
			return
		}

		message = ""

		ApiClient().getTestResults(identifier: identifier) { [weak self] envelope in

			self?.handleResponse(envelope)
		}
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
		title = "Burger Fetch Result"

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

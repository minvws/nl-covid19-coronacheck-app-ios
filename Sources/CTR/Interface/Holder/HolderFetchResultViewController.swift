/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import AppAuth

class FetchResultViewModel: Logging {

	var loggingCategory: String = "FetchResultViewModel"

	/// Configuration
	var configuration: ConfigurationDigidProtocol = Configuration()

	/// The open id client
	var openIdClient: OpenIdManaging

	/// The network manager
	var networkManager: NetworkManaging = Services.networkManager

	/// The crypto manager
	var cryptoManager: CryptoManagerProtocol = CryptoManager()

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	/// The user identifier
	var userIdentifier: String?

	weak var presentingViewController: UIViewController?

	// MARK: - Bindable properties

	@Bindable private(set) var primaryButtonTitle: String
	@Bindable private(set) var tertiaryButtonTitle: String?
	@Bindable private(set) var message: String = ""

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - userIdentifier: the user identifier
	init(
		coordinator: HolderCoordinatorDelegate,
		openIdClient: OpenIdManaging,
		userIdentifier: String?) {

		self.coordinator = coordinator
		primaryButtonTitle = "Login met Digid"
		self.userIdentifier = userIdentifier
		self.openIdClient = openIdClient
	}

	/// User tapped on the primary button
	func primaryButtonTapped(_ viewController: UIViewController) {

		self.presentingViewController = viewController
		fetchNonce()
	}

	/// Get the access token
	func getAccessToken() {

		guard let viewController = presentingViewController else {
			message = "Can't present login"
			return
		}

		openIdClient.requestAccessToken(
			presenter: viewController) { [weak self] accessToken in

			self?.message = "Access token: \(accessToken ?? "nil")"
			if let token = accessToken {
				self?.getTestResults(token)
			}
		} onError: { [weak self] error in
			self?.message = "Authorization error: \(error?.localizedDescription ?? "Unknown error")"
		}
	}

	/// Fetch a nonce from the server
	func fetchNonce() {

		networkManager.getNonce { [weak self] resultwrapper in

			switch resultwrapper {
				case let .success(envelope):
					
					self?.cryptoManager.setNonce(envelope.nonce)
					self?.cryptoManager.setStoken(envelope.stoken)
					self?.cryptoManager.debug()
					self?.getAccessToken()
				case let .failure(networkError):

					self?.logError("Can't fetch the nonce: \(networkError.localizedDescription)")
					self?.message = "Can't connect"
			}
		}
	}

	/// Post the access token
	/// - Parameter accessToken: the access token
	func getTestResults(_ accessToken: String) {

		if let icm = cryptoManager.generateCommitmentMessage(),
		   let icmDictionary = icm.convertToDictionary(),
		   let stoken = cryptoManager.getStoken() {

			let dictionary: [String: AnyObject] = [
				"access_token": accessToken as AnyObject,
				"stoken": stoken as AnyObject,
				"icm": icmDictionary as AnyObject
			]

			networkManager.fetchTestResultsWithISM(dictionary: dictionary) { [weak self] resultwrapper in

				switch resultwrapper {
					case let .success((_, data)):
						self?.handleTestProofsResponse(data)
					case let .failure(networkError):
						self?.logError("Can't fetch the IsM: \(networkError.localizedDescription)")
						self?.message = "Can't connect"
				}
			}
		}
	}

	private func handleTestProofsResponse(_ data: Data?) {

		if let unwrapped = data {

			logDebug("ISM Response: \(String(decoding: unwrapped, as: UTF8.self))")
		}

		cryptoManager.setProofs(data)

		// Show the button
		tertiaryButtonTitle = "Genereer toegangsbewijs"
	}

	/// User tapped on the third button
	func tertiaryButtonTapped() {

		coordinator?.navigateToHolderQR()
	}
}

class HolderFetchResultViewController: BaseViewController {

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
		viewModel.$tertiaryButtonTitle.binding = {

			self.sceneView.tertiaryTitle = $0 ?? ""
		}
		viewModel.$message.binding = {

			self.sceneView.message = $0
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in

			guard let strongSelf = self else {
				return
			}

			self?.viewModel.primaryButtonTapped(strongSelf)
		}

		sceneView.tertiaryButtonTappedCommand = { [weak self] in

			self?.viewModel.tertiaryButtonTapped()
		}
	}
}

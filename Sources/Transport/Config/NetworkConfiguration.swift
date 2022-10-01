/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Shared

public struct NetworkConfiguration {

    public struct EndpointConfiguration {
		public let scheme: String
		public let host: String
		public let port: Int?
		public let path: [String]
    }

    public let name: String
    public let api: EndpointConfiguration
	public let cdn: EndpointConfiguration

	public static let development = NetworkConfiguration(
		name: "DEV",
		api: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.acc.coronacheck.nl" : "verifier-api.acc.coronacheck.nl",
			port: nil,
			path: ["v8"]
		),
		cdn: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api-cdn.acc.coronacheck.nl" : "verifier-api-cdn.acc.coronacheck.nl",
			port: nil,
			path: ["v8"]
		)
	)

	public static let test = NetworkConfiguration(
		name: "TEST",
		api: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.test.coronacheck.nl" : "verifier-api.test.coronacheck.nl",
			port: nil,
			path: ["v8"]
		),
		cdn: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.test.coronacheck.nl" : "verifier-api.test.coronacheck.nl",
			port: nil,
			path: ["v8"]
		)
	)

	public static let acceptance = NetworkConfiguration(
		name: "ACC",
		api: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.acc.coronacheck.nl" : "verifier-api.acc.coronacheck.nl",
			port: nil,
			path: ["v8"]
		),
		cdn: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api-cdn.acc.coronacheck.nl" : "verifier-api-cdn.acc.coronacheck.nl",
			port: nil,
			path: ["v8"]
		)
	)

	public static let production = NetworkConfiguration(
		name: "Production",
		api: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.coronacheck.nl" : "verifier-api.coronacheck.nl",
			port: nil,
			path: ["v8"]
		),
		cdn: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api-cdn.coronacheck.nl" : "verifier-api-cdn.coronacheck.nl",
			port: nil,
			path: ["v8"]
		)
	)

	/// The access tokens url
	var eventAccessTokensUrl: URL? {

		return self.combine(path: Endpoint.accessTokens, fromCdn: false)
	}

	/// The nonce url
	var prepareIssueUrl: URL? {

		return self.combine(path: Endpoint.prepareIssue, fromCdn: false)
	}

	/// The signer url
	var credentialUrl: URL? {

		return self.combine(path: Endpoint.getCredentials, fromCdn: false)
	}

	/// The coupling url
	var couplingUrl: URL? {

		return self.combine(path: Endpoint.coupling, fromCdn: false)
	}

	/// The public keys url
	var publicKeysUrl: URL? {

		return self.combine(path: Endpoint.publicKeys, fromCdn: true)
	}

	/// The remote configuration url
    var remoteConfigurationUrl: URL? {

		return self.combine(path: Endpoint.remoteConfiguration, fromCdn: true)
    }

	/// The providers url
	var providersUrl: URL? {

		return self.combine(path: Endpoint.providers, fromCdn: true)
	}

	/// Combine the endpoint info into an url
	/// - Parameters:
	///   - path: the path information
	///   - fromCdn: True if we use a cdn for this path
	///   - params: optional query parameters
	/// - Returns: an url to the enpoint
	private func combine(path: Path, fromCdn: Bool) -> URL? {

		let endpointConfig = fromCdn ? cdn : api
        var urlComponents = URLComponents()
        urlComponents.scheme = endpointConfig.scheme
        urlComponents.host = endpointConfig.host
        urlComponents.port = endpointConfig.port
		urlComponents.path = "/" + (endpointConfig.path + path.components).joined(separator: "/")
		urlComponents.path = urlComponents.path.replacingOccurrences(of: "//", with: "/")

        return urlComponents.url
    }
}
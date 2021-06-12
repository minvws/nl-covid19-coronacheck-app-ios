/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

struct NetworkConfiguration {

    struct EndpointConfiguration {
        let scheme: String
        let host: String
        let port: Int?
        let path: [String]
    }

    let name: String
    let api: EndpointConfiguration
	let cdn: EndpointConfiguration

    static let development = NetworkConfiguration(
        name: "Development",
        api: .init(
            scheme: "https",
            host: "api-ct.bananenhalen.nl",
            port: nil,
            path: ["v4"]
        ),
		cdn: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: ["v4"]
		)
    )

    static let test = NetworkConfiguration(
        name: "Test",
		api: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: ["v4"]
		),
		cdn: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: ["v4"]
		)
    )

	static let acceptance = NetworkConfiguration(
		name: "ACC",
		api: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.acc.coronacheck.nl" : "verifier-api.acc.coronacheck.nl",
			port: nil,
			path: ["v4"]
		),
		cdn: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.acc.coronacheck.nl" : "verifier-api.acc.coronacheck.nl",
			port: nil,
			path: ["v4"]
		)
	)

	static let production = NetworkConfiguration(
		name: "Production",
		api: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.coronacheck.nl" : "verifier-api.coronacheck.nl",
			port: nil,
			path: ["v4"]
		),
		cdn: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.coronacheck.nl" : "verifier-api.coronacheck.nl",
			port: nil,
			path: ["v4"]
		)
	)

	/// The access tokens url
	var vaccinationAccessTokensUrl: URL? {

		return self.combine(path: Endpoint.accessTokens, fromCdn: false)
	}

	/// The nonce url
	var prepareIssueUrl: URL? {

		return self.combine(path: Endpoint.prepareIssue, fromCdn: false)
	}

	/// The nonce url
	var credentialUrl: URL? {

		return self.combine(path: Endpoint.getCredentials, fromCdn: false)
	}

	/// The public keys url
	var publicKeysUrl: URL? {

		return self.combine(path: Endpoint.publicKeys, fromCdn: false)
	}

	/// The remote configuration url
    var remoteConfigurationUrl: URL? {

		return self.combine(path: Endpoint.remoteConfiguration, fromCdn: false)
    }

	/// The providers url
	var providersUrl: URL? {

		return self.combine(path: Endpoint.providers, fromCdn: false)
	}

	/// Combine the endpoint info into an url
	/// - Parameters:
	///   - path: the path information
	///   - fromCdn: True if we use a cdn for this path
	///   - params: optional query parameters
	/// - Returns: an url to the enpoint
	private func combine(path: Path, fromCdn: Bool, params: [String: String] = [:]) -> URL? {

		let endpointConfig = fromCdn ? cdn : api
        var urlComponents = URLComponents()
        urlComponents.scheme = endpointConfig.scheme
        urlComponents.host = endpointConfig.host
        urlComponents.port = endpointConfig.port
		urlComponents.path = "/" + (endpointConfig.path + path.components).joined(separator: "/")
		urlComponents.path = urlComponents.path.replacingOccurrences(of: "//", with: "/")

        if !params.isEmpty {
			urlComponents.path += "/"
            urlComponents.percentEncodedQueryItems = params.compactMap { parameter in
                guard let name = parameter.key.addingPercentEncoding(withAllowedCharacters: urlQueryEncodedCharacterSet),
                    let value = parameter.value.addingPercentEncoding(withAllowedCharacters: urlQueryEncodedCharacterSet) else {
                    return nil
                }
                return URLQueryItem(name: name, value: value)
            }
        }
        return urlComponents.url
    }

    private var urlQueryEncodedCharacterSet: CharacterSet = {
        // WARNING: Do not remove this code, this will break signature validation on the backend.
        // specify characters which are allowed to be unespaced in the queryString, note the `inverted`
        let characterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
        return characterSet
    }()
}

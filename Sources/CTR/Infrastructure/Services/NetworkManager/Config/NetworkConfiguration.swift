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
        let sslSignature: [Certificate.Signature]? // SSL pinning certificate, nil = no pinning
    }

    let name: String
    let api: EndpointConfiguration
	let cdn: EndpointConfiguration
    
    func sslSignatures(forHost host: String) -> [Certificate.Signature]? {
        if api.host == host { return api.sslSignature }
		if cdn.host == host { return cdn.sslSignature }

        return nil
    }

    static let development = NetworkConfiguration(
        name: "Development",
        api: .init(
            scheme: "https",
            host: "api-ct.bananenhalen.nl",
            port: nil,
            path: [""],
            sslSignature: nil
        ),
		cdn: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: [""],
			sslSignature: nil
		)
    )

    static let test = NetworkConfiguration(
        name: "Test",
		api: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: [""],
			sslSignature: nil
		),
		cdn: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: [""],
			sslSignature: nil
		)
    )

	static let acceptance = NetworkConfiguration(
		name: "ACC",
		api: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.acc.coronacheck.nl" : "verifier-api.acc.coronacheck.nl",
			port: nil,
			path: ["v1"],
			sslSignature: [Certificate.SSL.apiSignature, Certificate.SSL.apiV2Signature]
		),
		cdn: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.acc.coronacheck.nl" : "verifier-api.acc.coronacheck.nl",
			port: nil,
			path: ["v1"],
			sslSignature: nil // [Certificate.SSL.cdnSignature, Certificate.SSL.cdnV2V3Signature],
		)
	)

	static let production = NetworkConfiguration(
		name: "Production",
		api: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.coronacheck.nl" : "verifier-api.coronacheck.nl",
			port: nil,
			path: ["v1"],
			sslSignature: [Certificate.SSL.apiSignature, Certificate.SSL.apiV2Signature]
		),
		cdn: .init(
			scheme: "https",
			host: AppFlavor.flavor == .holder ? "holder-api.coronacheck.nl" : "verifier-api.coronacheck.nl",
			port: nil,
			path: ["v1"],
			sslSignature: nil // [Certificate.SSL.cdnSignature, Certificate.SSL.cdnV2V3Signature],
		)
	)

	/// The remote configuration url
    var remoteConfigurationUrl: URL? {

		return self.combine(path: Endpoint.remoteConfiguration, fromCdn: false)
    }

	/// The nonce url
	var nonceUrl: URL? {

		return self.combine(path: Endpoint.nonce, fromCdn: false)
	}

	/// The nonce url
	var testResultIsmUrl: URL? {

		return self.combine(path: Endpoint.testResultIsm, fromCdn: false)
	}

	/// The providers url
	var testProvidersUrl: URL? {

		return self.combine(path: Endpoint.testProviders, fromCdn: false)
	}

	/// The types url
	var testTypesUrl: URL? {

		return self.combine(path: Endpoint.testTypes, fromCdn: false)
	}

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

	func combine(components: URLComponents, params: [String: String] = [:]) -> URL? {

		var urlComponents = components

		if !params.isEmpty {
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

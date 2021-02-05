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
        let tokenParams: [String: String]
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
            sslSignature: nil,
            tokenParams: [:]
        ),
		cdn: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: [""],
			sslSignature: nil,
			tokenParams: [:]
		)
    )

    static let test = NetworkConfiguration(
        name: "Test",
		api: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: [""],
			sslSignature: nil,
			tokenParams: [:]
		),
		cdn: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: [""],
			sslSignature: nil,
			tokenParams: [:]
		)
    )

	static let acceptance = NetworkConfiguration(
		name: "ACC",
		api: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: [""],
			sslSignature: nil, // [Certificate.SSL.apiSignature, Certificate.SSL.apiV2Signature],
			tokenParams: [:]
		),
		cdn: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: [""],
			sslSignature: nil, // [Certificate.SSL.cdnSignature, Certificate.SSL.cdnV2V3Signature],
			tokenParams: [:]
		)
	)

	static let production = NetworkConfiguration(
		name: "Production",
		api: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: ["v1"],
			sslSignature: nil, // [Certificate.SSL.apiSignature, Certificate.SSL.apiV2Signature],
			tokenParams: [:]
		),
		cdn: .init(
			scheme: "https",
			host: "api-ct.bananenhalen.nl",
			port: nil,
			path: [""],
			sslSignature: nil, // [Certificate.SSL.cdnSignature, Certificate.SSL.cdnV2V3Signature],
			tokenParams: [:]
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

	private func combine(path: Path, fromCdn: Bool, params: [String: String] = [:]) -> URL? {
		let endpointConfig = fromCdn ? cdn : api
        var urlComponents = URLComponents()
        urlComponents.scheme = endpointConfig.scheme
        urlComponents.host = endpointConfig.host
        urlComponents.port = endpointConfig.port
		urlComponents.path = "/" + (endpointConfig.path + path.components).joined(separator: "/")
		urlComponents.path = urlComponents.path.replacingOccurrences(of: "//", with: "/")

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

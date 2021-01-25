//
//  URLRequest+Utils.swift
//  Alarm112
//
//  Created by Rogier van de Pol on 14/11/2018.
//  Copyright © 2020 Landelijke Meldkamer Samenwerking. All rights reserved.
//

import Foundation

extension URLRequest {

	/// Add headers to an URLRequest
	/// - Parameter headers: the headers to add
	mutating func addHeaders(_ headers: [String: String?]) {
		
		for (key, value) in headers {
			setValue(value, forHTTPHeaderField: key)
		}
	}
}

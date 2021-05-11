/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

class CredentialModel {

	static let entityName = "Credential"

	@discardableResult class func create(
		qrData: Data,
		validFrom: Date,
		greenCard: GreenCard,
		managedContext: NSManagedObjectContext) -> Credential? {

		if let object = NSEntityDescription.insertNewObject(
			forEntityName: entityName,
			into: managedContext) as? Credential {

			object.qrData = qrData
			object.validFrom = validFrom
			object.greenCard = greenCard

			return object
		}
		return nil
	}
}

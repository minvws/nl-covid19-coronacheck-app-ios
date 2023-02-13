/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Models
import Transport
import Persistence

extension EuCredentialAttributes {
	var identity: EventFlow.Identity {

		return EventFlow.Identity(
			infix: nil,
			firstName: digitalCovidCertificate.name.givenName,
			lastName: digitalCovidCertificate.name.familyName,
			birthDateString: digitalCovidCertificate.dateOfBirth
		)
	}

	var eventMode: EventMode? {

		if digitalCovidCertificate.vaccinations?.first != nil {
			return .vaccination
		} else if digitalCovidCertificate.recoveries?.first != nil {
			return .recovery
		} else if digitalCovidCertificate.tests?.first != nil {
			return .test(.dcc)
		}
		return nil
	}
}

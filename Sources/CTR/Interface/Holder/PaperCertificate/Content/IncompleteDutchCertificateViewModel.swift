/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

final class IncompleteDutchCertificateViewModel: Logging {
	
	@Bindable private(set) var title: String
	@Bindable private(set) var paragraphA: String
	@Bindable private(set) var paragraphB: String
	@Bindable private(set) var paragraphC: String
	
	@Bindable private(set) var secondaryButtonA: String
	@Bindable private(set) var secondaryButtonB: String
	
	init() {
		title = "Geen Nederlands.."
		paragraphA = "Je vaccinatiebewijs.. "
		paragraphB = "Corona gehad.. ?"
		paragraphC = "Meer weten?"
		
		secondaryButtonA = "Voeg tweede.."
		secondaryButtonB = "Voeg een positieve.. "
	}
	
	func didTapSecondaryButtonA() {
		print("Button A..")
	}
	
	func didTapSecondaryButtonB() {
		print("Button B..")
	}
}

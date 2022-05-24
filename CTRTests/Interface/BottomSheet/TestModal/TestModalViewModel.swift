/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
@testable import CTR

final class TestModalViewModel: Logging {
	
	@Bindable private(set) var testTitle = "Veilig op reis met je coronabewijs"
	
	@Bindable private(set) var testMessage = """
Ga je naar het buitenland? Check vooraf op wijsopreis.nl of je een coronabewijs nodig hebt. Je kunt een bewijs maken als je bent gevaccineerd, uit een test blijkt dat je geen corona had, of als je corona hebt gehad en hersteld bent. Download de app voor een bewijs op je telefoon, of maak een papieren bewijs.
	
CoronaCheck en CoronaCheck Scanner zijn ontwikkeld door het ministerie van Volksgezondheid, Welzijn en Sport. Zowel de apps als de papieren versie via CoronaCheck.nl waren niet tot stand gekomen zonder de hulp van tientallen experts en ervaringsdeskundigen. Ook heeft een grote open source community tijdens de ontwikkeling meegekeken en getest.

De broncode van de app en de achterliggende systemen zijn volledig openbaar. Je kunt alle code terugvinden op GitHub. Zo is de precieze werking van de app controleerbaar en helpen de vele ogen bij het opsporen van eventuele kwetsbaarheden.
	
De CoronaCheck is, net zoals de CoronaMelder, open ontwikkeld. Dat betekent dat alle code open source is. Een grote open source community heeft tijdens de ontwikkeling van CoronaCheck meegekeken en getest. Je kunt de code en designs bekijken op het GitHub-account van VWS.
"""
}

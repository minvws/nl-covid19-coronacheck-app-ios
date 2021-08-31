/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData
@testable import CTR

extension GreenCard {

	static func sampleDomesticCredentialsVaccinationExpiringIn10DaysWithMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.sampleVaccination(eventTime: 8 * days * ago, expirationTime: 40 * days * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.sample(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * ago, expirationTime: 0 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 0 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * fromNow, expirationTime: 2 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * fromNow, expirationTime: 3 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * fromNow, expirationTime: 4 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * fromNow, expirationTime: 5 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * fromNow, expirationTime: 6 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * fromNow, expirationTime: 7 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * fromNow, expirationTime: 8 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 8 * days * fromNow, expirationTime: 9 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 9 * days * fromNow, expirationTime: 10 * days * fromNow, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	static func sampleDomesticCredentialsVaccinationExpiringIn10DaysWithMoreToFetchWithValidTest(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.sampleVaccination(eventTime: 8 * days * ago, expirationTime: 40 * days * fromNow, dataStoreManager: dataStoreManager),
			Origin.sampleTest(eventTime: 4 * hours * ago, expirationTime: 20 * hours * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.sample(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * ago, expirationTime: 0 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 0 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * fromNow, expirationTime: 2 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * fromNow, expirationTime: 3 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * fromNow, expirationTime: 4 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * fromNow, expirationTime: 5 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * fromNow, expirationTime: 6 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * fromNow, expirationTime: 7 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * fromNow, expirationTime: 8 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 8 * days * fromNow, expirationTime: 9 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 9 * days * fromNow, expirationTime: 10 * days * fromNow, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	static func sampleDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.sampleVaccination(eventTime: 8 * days * ago, expirationTime: 30 * days * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.sample(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * ago, expirationTime: 0 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 0 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * fromNow, expirationTime: 2 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * fromNow, expirationTime: 3 * days * fromNow, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	static func sampleDomesticCredentialsBecomingValidIn28DaysForOneYearWithNoInitialCredentials(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.sampleVaccination(eventTime: 2 * hours * ago, validFromDate: 28 * days * fromNow, expirationTime: 1 * years * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = []

		return greencard
	}

	static func sampleDomesticCredentialsBecomingValidIn3DaysForOneYearWithNoInitialCredentials(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.sampleVaccination(eventTime: 25 * days * ago, validFromDate: 3 * days * fromNow, expirationTime: 1 * years * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = []

		return greencard
	}

	static func sampleDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.sampleVaccination(eventTime: 8 * days * ago, expirationTime: 30 * days * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.sample(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	static func sampleDomesticCredentialsExpiringWithNoMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.sampleVaccination(eventTime: 8 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.sample(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * ago, expirationTime: 0 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	static func sampleDomesticCredentialsExpiredWithNoMoreToFetch(dataStoreManager: DataStoreManager) -> GreenCard {
		let greencard = GreenCard(context: dataStoreManager.managedObjectContext())
		greencard.type = GreenCardType.domestic.rawValue

		greencard.origins = [
			Origin.sampleVaccination(eventTime: 8 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager)
		]

		greencard.credentials = [
			Credential.sample(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager)
		]
		return greencard
	}

	// MARK: - International

	static func sampleInternationalCredentialsVaccinationExpiringIn10DaysWithMoreToFetchWithValidTest(dataStoreManager: DataStoreManager) -> [GreenCard] {
		let vaccineGreencard = GreenCard(context: dataStoreManager.managedObjectContext())
		vaccineGreencard.type = GreenCardType.eu.rawValue
		vaccineGreencard.origins = [
			Origin.sampleVaccination(eventTime: 8 * days * ago, expirationTime: 40 * days * fromNow, dataStoreManager: dataStoreManager)
		]
		vaccineGreencard.credentials = [
			Credential.sample(validFrom: 8 * days * ago, expirationTime: 7 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * ago, expirationTime: 6 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * ago, expirationTime: 5 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * ago, expirationTime: 4 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * ago, expirationTime: 3 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * ago, expirationTime: 2 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * ago, expirationTime: 1 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * ago, expirationTime: 0 * days * ago, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 0 * days * ago, expirationTime: 1 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 1 * days * fromNow, expirationTime: 2 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 2 * days * fromNow, expirationTime: 3 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 3 * days * fromNow, expirationTime: 4 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 4 * days * fromNow, expirationTime: 5 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 5 * days * fromNow, expirationTime: 6 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 6 * days * fromNow, expirationTime: 7 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 7 * days * fromNow, expirationTime: 8 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 8 * days * fromNow, expirationTime: 9 * days * fromNow, dataStoreManager: dataStoreManager),
			Credential.sample(validFrom: 9 * days * fromNow, expirationTime: 10 * days * fromNow, dataStoreManager: dataStoreManager)
		]

		let testGreencard = GreenCard(context: dataStoreManager.managedObjectContext())
		testGreencard.type = GreenCardType.eu.rawValue
		testGreencard.origins = [
			Origin.sampleTest(eventTime: 4 * hours * ago, expirationTime: 20 * hours * fromNow, dataStoreManager: dataStoreManager)
		]
		testGreencard.credentials = [
			Credential.sample(validFrom: 4 * hours * ago, expirationTime: 20 * hours * fromNow, dataStoreManager: dataStoreManager)
		]

		return [testGreencard, vaccineGreencard]
	}
}

extension Origin {
	static func sampleVaccination(eventTime: TimeInterval, validFromDate: TimeInterval? = nil, expirationTime: TimeInterval, dataStoreManager: DataStoreManager) -> Origin {
		let origin = Origin(context: dataStoreManager.managedObjectContext())
		origin.type = OriginType.vaccination.rawValue
		origin.eventDate = now.addingTimeInterval(eventTime)
		origin.validFromDate = validFromDate.map { now.addingTimeInterval($0) } ?? origin.eventDate
		origin.expirationTime = now.addingTimeInterval(expirationTime)
		return origin
	}

	static func sampleTest(eventTime: TimeInterval, expirationTime: TimeInterval, dataStoreManager: DataStoreManager) -> Origin {
		let origin = Origin(context: dataStoreManager.managedObjectContext())
		origin.type = OriginType.test.rawValue
		origin.eventDate = now.addingTimeInterval(eventTime)
		origin.validFromDate = origin.eventDate
		origin.expirationTime = now.addingTimeInterval(expirationTime)
		return origin
	}
}

extension Credential {
	static func sample(validFrom: TimeInterval, expirationTime: TimeInterval, dataStoreManager: DataStoreManager) -> Credential {
		let credential = Credential(context: dataStoreManager.managedObjectContext())
		credential.data = "".data(using: .utf8)
		credential.version = 1337
		credential.validFrom = now.addingTimeInterval(validFrom)
		credential.expirationTime = now.addingTimeInterval(expirationTime)
		return credential
	}
}

extension WalletManagerSpy {

	func loadDomesticCredentialsExpiringIn10DaysWithMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.sampleDomesticCredentialsVaccinationExpiringIn10DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.sampleDomesticCredentialsExpiringIn3DaysWithMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.sampleDomesticCredentialsExpiredWithMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticCredentialsExpiredWithNoMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.sampleDomesticCredentialsExpiredWithNoMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticCredentialsExpiringWithNoMoreToFetch(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.sampleDomesticCredentialsExpiringWithNoMoreToFetch(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticEmptyCredentialsWithDistantFutureValidity(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.sampleDomesticCredentialsBecomingValidIn28DaysForOneYearWithNoInitialCredentials(dataStoreManager: dataStoreManager)
		]
	}

	func loadDomesticEmptyCredentialsWithImminentFutureValidity(dataStoreManager: DataStoreManager) {

		stubbedGreencardsWithUnexpiredOriginsResult = [
			.sampleDomesticCredentialsBecomingValidIn3DaysForOneYearWithNoInitialCredentials(dataStoreManager: dataStoreManager)
		]
	}
}

extension HolderDashboardViewModel.MyQRCard.Origin {

	// Already Valid

	static func validOneDayAgo_vaccination_expires3DaysFromNow() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.vaccination,
			eventDate: now.addingTimeInterval(1 * day * ago),
			expirationTime: now.addingTimeInterval(3 * days * fromNow),
			validFromDate: now.addingTimeInterval(1 * day * ago)
		)
	}

	static func valid30DaysAgo_vaccination_expires60SecondsFromNow() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.vaccination,
			eventDate: now.addingTimeInterval(30 * day * ago),
			expirationTime: now.addingTimeInterval(60 * seconds * fromNow),
			validFromDate: now.addingTimeInterval(30 * day * ago)
		)
	}

	static func validOneHourAgo_test_expires23HoursFromNow() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.test,
			eventDate: now.addingTimeInterval(1 * hour * ago),
			expirationTime: now.addingTimeInterval(23 * hours * fromNow),
			validFromDate: now.addingTimeInterval(1 * hour * ago)
		)
	}

	static func validOneDayAgo_test_expires5MinutesFromNow() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.test,
			eventDate: now.addingTimeInterval(1 * day * ago),
			expirationTime: now.addingTimeInterval(5 * minutes * fromNow),
			validFromDate: now.addingTimeInterval(1 * day * ago)
		)
	}

	static func validOneHourAgo_recovery_expires300DaysFromNow() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.recovery,
			eventDate: now.addingTimeInterval(1 * hour * ago),
			expirationTime: now.addingTimeInterval(300 * days * fromNow),
			validFromDate: now.addingTimeInterval(1 * hour * ago)
		)
	}

	static func validOneMonthAgo_recovery_expires2HoursFromNow() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.recovery,
			eventDate: now.addingTimeInterval(30 * days * ago),
			expirationTime: now.addingTimeInterval(120 * minutes * fromNow),
			validFromDate: now.addingTimeInterval(30 * days * ago)
		)
	}

	static func eventNineDaysAgo_validFiveDaysFromNow_vaccination_expiresFourYearsLater() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.vaccination,
			eventDate: now.addingTimeInterval(9 * days * ago),
			expirationTime: now.addingTimeInterval(4 * years * fromNow),
			validFromDate: now.addingTimeInterval(5 * days * fromNow)
		)
	}

	// Valid in future

	static func validIn48Hours_vaccination_expires30DaysFromNow() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.vaccination,
			eventDate: now.addingTimeInterval(5 * days * ago),
			expirationTime: now.addingTimeInterval(30 * days * fromNow),
			validFromDate: now.addingTimeInterval(48 * hours * fromNow)
		)
	}

	static func validIn48Hours_recovery_expires300DaysFromNow() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.recovery,
			eventDate: now.addingTimeInterval(5 * days * ago),
			expirationTime: now.addingTimeInterval(300 * days * fromNow),
			validFromDate: now.addingTimeInterval(48 * hour * fromNow)
		)
	}

	// Expired

	static func validOneMonthAgo_vaccination_expired2DaysAgo() -> HolderDashboardViewModel.MyQRCard.Origin {
		.init(
			type: QRCodeOriginType.vaccination,
			eventDate: now.addingTimeInterval(30 * days * ago),
			expirationTime: now.addingTimeInterval(2 * days * ago),
			validFromDate: now.addingTimeInterval(14 * days * ago)
		)
	}
}

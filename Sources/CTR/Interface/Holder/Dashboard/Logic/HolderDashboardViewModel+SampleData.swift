//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

#if DEBUG
extension HolderDashboardViewModel {
	func injectSampleData(dataStoreManager: DataStoreManaging) {

		let context = dataStoreManager.backgroundContext()

		context.performAndWait {
			_ = Services.walletManager // ensure single entity Wallet is created.
			guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context)
			else { fatalError("expecting wallet to have been created") }

			guard (wallet.greenCards ?? [])?.count == 0 else { return } // swiftlint:disable:this empty_count

			guard let domesticGreenCard = GreenCardModel.create(type: .domestic, wallet: wallet, managedContext: context)
			else { fatalError("Could not creat a green card") }

			//		guard let euVaccinationGreenCard = GreenCardModel.create(type: .eu, wallet: wallet, managedContext: context)
			//		else { fatalError("Could not create a green card") }

			/// Event Date: the date of the event that took place e.g. your vaccination.
			/// Expiration Date: the date it expires
			/// ValidFrom Date: the date that the QR becomes valid.

			let ago: TimeInterval = -1
			let fromNow: TimeInterval = 1
			//		let seconds: TimeInterval = 1
			let minutes: TimeInterval = 60
			let hours: TimeInterval = 60 * minutes
			let days: TimeInterval = hours * 24

			//		create( type: .recovery,
			//				eventDate: Date().addingTimeInterval(14 * days * ago),
			//				expirationTime: Date().addingTimeInterval((10 * seconds * fromNow)),
			//				validFromDate: Date().addingTimeInterval(fromNow),
			//				greenCard: domesticGreenCard,
			//				managedContext: context)

			create( type: .vaccination,
					eventDate: Date().addingTimeInterval(14 * days * ago),
					expirationTime: Date().addingTimeInterval((365 * 4 * days * fromNow)),
					validFromDate: Date().addingTimeInterval(fromNow),
					greenCard: domesticGreenCard,
					managedContext: context)

			create( type: .test,
					eventDate: Date().addingTimeInterval(20 * hours * ago),
					expirationTime: Date().addingTimeInterval((20 * hours * fromNow)),
					validFromDate: Date().addingTimeInterval(20 * hours * ago),
					greenCard: domesticGreenCard,
					managedContext: context)

			dataStoreManager.save(context)
			print("did insert!")
		}
	}

	private func create(
		type: OriginType,
		eventDate: Date,
		expirationTime: Date,
		validFromDate: Date,
		greenCard: GreenCard,
		managedContext: NSManagedObjectContext) {

		OriginModel.create(
			type: type,
			eventDate: eventDate,
			expirationTime: expirationTime,
			validFromDate: validFromDate,
			greenCard: greenCard,
			managedContext: managedContext)

		CredentialModel.create(
			data: "".data(using: .utf8)!,
			validFrom: validFromDate,
			expirationTime: expirationTime,
			greenCard: greenCard,
			managedContext: managedContext)
	}
}
#endif

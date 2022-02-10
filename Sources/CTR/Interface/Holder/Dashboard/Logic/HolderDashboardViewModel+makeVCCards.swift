/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

extension HolderDashboardViewController.Card {

	static func makeHeaderMessageCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {

		guard !state.qrCards.isEmpty || !state.regionFilteredExpiredCards(validityRegion: validityRegion).isEmpty
		else { return [] }

		switch validityRegion {
			case .domestic:
				return [.headerMessage(
					message: L.holderDashboardIntroDomestic(),
					buttonTitle: nil
				)]
			case .europeanUnion:
				return [.headerMessage(
					message: L.holderDashboardIntroInternational(),
					buttonTitle: L.holderDashboardEmptyInternationalButton()
				)]
		}
	}

	static func makeAddCertificateCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard !state.shouldShowAddCertificateFooter else { return [] }
		return [
			.addCertificate(
				title: L.holder_dashboard_addCard_title(),
				didTapAdd: { [weak actionHandler] in
					actionHandler?.didTapAddCertificate()
				})
		]
	}
	
	static func makeDeviceHasClockDeviationCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard state.deviceHasClockDeviation && !state.qrCards.isEmpty else { return [] }
		return [
			.deviceHasClockDeviation(
				message: L.holderDashboardClockDeviationDetectedMessage(),
				callToActionButtonText: L.generalReadmore(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapDeviceHasClockDeviationMoreInfo()
				}
			)
		]
	}

	static func makeConfigAlmostOutOfDateCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard state.shouldShowConfigurationIsAlmostOutOfDateBanner else { return [] }
		return [
			.configAlmostOutOfDate(
				message: L.holderDashboardConfigIsAlmostOutOfDateCardMessage(),
				callToActionButtonText: L.holderDashboardConfigIsAlmostOutOfDateCardButton(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapConfigAlmostOutOfDateCTA()
				}
			)
		]
	}

	static func makeExpiredQRCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		return state.regionFilteredExpiredCards(validityRegion: validityRegion)
			.compactMap { expiredQR -> HolderDashboardViewController.Card? in
				
				let message = String.holderDashboardQRExpired(
					originType: expiredQR.type,
					region: expiredQR.region
				)
				let didTapClose: () -> Void = { [weak actionHandler] in
					actionHandler?.didTapCloseExpiredQR(expiredQR: expiredQR)
				}
				
				if case .vaccination = expiredQR.type, case .domestic = expiredQR.region {
					return .expiredVaccinationQR(
						message: message,
						callToActionButtonText: L.generalReadmore(),
						didTapCallToAction: { [weak actionHandler] in
							actionHandler?.didTapExpiredDomesticVaccinationQRMoreInfo()
						},
						didTapClose: didTapClose
					)
				} else {
					return .expiredQR(message: message, didTapClose: didTapClose)
				}
			}
	}
	
	static func makeEmptyStateDescriptionCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		guard !state.dashboardHasQRCards(for: validityRegion) else { return [] }
		
		switch validityRegion {
			case .domestic:
				return [HolderDashboardViewController.Card.emptyStateDescription(
					message: L.holderDashboardEmptyDomesticMessage(),
					buttonTitle: nil
				)]
			case .europeanUnion:
				return [HolderDashboardViewController.Card.emptyStateDescription(
					message: L.holderDashboardEmptyInternationalMessage(),
					buttonTitle: L.holderDashboardEmptyInternationalButton()
				)]
		}
	}
	
	static func makeEmptyStatePlaceholderImageCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		guard !state.dashboardHasQRCards(for: validityRegion) else { return [] }
		guard !state.shouldShowCompleteYourVaccinationAssessmentBanner(for: validityRegion) else { return [] }
		guard !state.shouldShowVaccinationAssessmentInvalidOutsideNLBanner(for: validityRegion) else { return [] }
	
		switch validityRegion {
			case .domestic:
				guard let domesticImage = I.dashboard.domestic() else { return [] }
				return [HolderDashboardViewController.Card.emptyStatePlaceholderImage(
					image: domesticImage,
					title: L.holderDashboardEmptyDomesticTitle()
				)]
			case .europeanUnion:
				guard let internationalImage = I.dashboard.international() else { return [] }
				return [HolderDashboardViewController.Card.emptyStatePlaceholderImage(
					image: internationalImage,
					title: L.holderDashboardEmptyInternationalTitle()
				)]
		}
	}
	
	static func makeRecommendCoronaMelderCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State
	) -> [HolderDashboardViewController.Card] {
		let regionFilteredQRCards = state.regionFilteredQRCards(validityRegion: validityRegion)
		
		guard !regionFilteredQRCards.isEmpty,
			  !regionFilteredQRCards.contains(where: { $0.shouldShowErrorBeneathCard })
		else { return [] }
		
		return [HolderDashboardViewController.Card.recommendCoronaMelder]
	}
	
	static func makeTestOnlyValidFor3GCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard validityRegion == .domestic else { return [] }
		guard state.shouldShowDomestic3GTestBanner else { return [] }
		
		return [HolderDashboardViewController.Card.testOnlyValidFor3G(
			message: L.holder_my_overview_3g_test_validity_card(),
			callToActionButtonText: L.generalReadmore(),
			didTapCallToAction: { [weak actionHandler] in
				actionHandler?.didTapTestOnlyValidFor3GMoreInfo()
			})
		]
	}
	
	/// for each origin which is in the other region but not in this one, add a new MessageCard to explain.
	/// e.g. "Je vaccinatie is niet geldig in Europa. Je hebt alleen een Nederlandse QR-code."
	static func makeOriginNotValidInThisRegionCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		now: Date,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		return localizedOriginsValidOnlyInOtherRegionsMessages(qrCards: state.qrCards, thisRegion: validityRegion, now: now)
			.sorted(by: { $0.originType.customSortIndex < $1.originType.customSortIndex })
			.map { originType, message in
				return .originNotValidInThisRegion(
					message: message,
					callToActionButtonText: L.generalReadmore(),
					didTapCallToAction: { [weak actionHandler] in
						actionHandler?.didTapOriginNotValidInThisRegionMoreInfo(
							originType: originType,
							validityRegion: validityRegion
						)
					}
				)
			}
	}
	
	static func makeRecommendedUpdateCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		guard state.shouldShowRecommendedUpdateBanner else { return [] }
		return [
			.recommendedUpdate(
				message: L.recommended_update_card_description(),
				callToActionButtonText: L.recommended_update_card_action(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapRecommendedUpdate()
				}
			)
		]
	}

	static func makeNewValidityInfoForVaccinationAndRecoveriesCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
	
		guard validityRegion == .domestic, state.shouldShowNewValidityInfoForVaccinationsAndRecoveriesBanner else { return [] }
		return [
			.newValidityInfoForVaccinationAndRecoveries(
				title: L.holder_dashboard_newvaliditybanner_title(),
				buttonText: L.holder_dashboard_newvaliditybanner_action(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapNewValidityBannerMoreInfo()
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapNewValidityBannerClose()
				}
			)
		]
	}
	
	static func makeCompleteYourVaccinationAssessmentCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
	
		guard state.shouldShowCompleteYourVaccinationAssessmentBanner(for: validityRegion) else { return [] }
		return [
			.completeYourVaccinationAssessment(
				title: L.holder_dashboard_visitorpassincompletebanner_title(),
				buttonText: L.holder_dashboard_visitorpassincompletebanner_button_makecomplete(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapCompleteYourVaccinationAssessmentMoreInfo()
				}
			)
		]
	}
	
	static func makeRecommendToAddYourBoosterCard(
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
	
		guard state.shouldShowRecommendationToAddYourBooster else { return [] }
		return [
			.recommendToAddYourBooster(
				title: L.holder_dashboard_addBoosterBanner_title(),
				buttonText: L.holder_dashboard_addBoosterBanner_button_addBooster(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapRecommendToAddYourBooster()
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapRecommendToAddYourBoosterClose()
				}
			)
		]
	}
	
	static func makeDisclosurePolicyInformation1GBanner(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard validityRegion == .domestic, state.shouldShow1GOnlyDisclosurePolicyBecameActiveBanner else { return [] }
		
		return [
			.disclosurePolicyInformation(
				title: L.holder_dashboard_only1GaccessBanner_title(),
				buttonText: L.holder_dashboard_only1GaccessBanner_button(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation1GBannerMoreInformation()
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation1GBannerClose()
				}
			)
		]
	}
	
	static func makeDisclosurePolicyInformation3GBanner(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard validityRegion == .domestic, state.shouldShow3GOnlyDisclosurePolicyBecameActiveBanner else { return [] }
		
		return [
			.disclosurePolicyInformation(
				title: L.holder_dashboard_only3GaccessBanner_title(),
				buttonText: L.holder_dashboard_only3GaccessBanner_button(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation3GBannerMoreInformation()
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation3GBannerClose()
				}
			)
		]
	}
	
	static func makeDisclosurePolicyInformation1GWith3GBanner(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard validityRegion == .domestic, state.shouldShow3GWith1GDisclosurePolicyBecameActiveBanner else { return [] }
		
		return [
			.disclosurePolicyInformation(
				title: L.holder_dashboard_3Gand1GaccessBanner_title(),
				buttonText: L.holder_dashboard_3Gand1GaccessBanner_button(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation1GWith3GBannerMoreInformation()
				},
				didTapClose: { [weak actionHandler] in
					actionHandler?.didTapDisclosurePolicyInformation1GWith3GBannerClose()
				}
			)
		]
	}
	
	static func makeVaccinationAssessmentInvalidOutsideNLCard(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {
		
		guard state.shouldShowVaccinationAssessmentInvalidOutsideNLBanner(for: validityRegion) else { return [] }
		
		return [
			.vaccinationAssessmentInvalidOutsideNL(
				title: L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title(),
				buttonText: L.generalReadmore(),
				didTapCallToAction: { [weak actionHandler] in
					actionHandler?.didTapVaccinationAssessmentInvalidOutsideNLMoreInfo()
				}
			)
		]
	}
	
	/// Map a `QRCard` to a `VC.Card`:
	static func makeQRCards(
		validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		localDisclosurePolicy: DisclosurePolicy, // the disclosure policy for this group of cards (vs state.activeDisclosurePolicyMode)
		actionHandler: HolderDashboardCardUserActionHandling,
		remoteConfigManager: RemoteConfigManaging
	) -> [HolderDashboardViewController.Card] {
		return state.regionFilteredQRCards(validityRegion: validityRegion)
			.flatMap { (qrcardDataItem: HolderDashboardViewModel.QRCard) -> [HolderDashboardViewController.Card] in
				qrcardDataItem.toViewControllerCards(
					state: state,
					localDisclosurePolicy: localDisclosurePolicy,
					actionHandler: actionHandler
				)
			}
	}
}

extension HolderDashboardViewModel.QRCard {

	fileprivate func toViewControllerCards(
		state: HolderDashboardViewModel.State,
		localDisclosurePolicy: DisclosurePolicy, // the disclosure policy for this card (vs state.activeDisclosurePolicyMode)
		actionHandler: HolderDashboardCardUserActionHandling
	) -> [HolderDashboardViewController.Card] {

		var cards = [HolderDashboardViewController.Card]()
		
		switch self.region {
			case .netherlands:
				
				// Certain combinations preclude showing _any_ QR Cards
				// , in which case just return nothing
			
				switch (state.activeDisclosurePolicyMode, localDisclosurePolicy) {
					case (.exclusive1G, .policy1G),
						(.exclusive3G, .policy3G),
						(.combined1gAnd3g, .policy1G),
						(.combined1gAnd3g, .policy3G),
						(.exclusive1G, .policy3G):
						break
					case (.exclusive3G, .policy1G):
						return []
				}
			
				cards += [HolderDashboardViewController.Card.domesticQR(
					disclosurePolicyLabel: localDisclosurePolicy.localization,
					title: L.holderDashboardQrTitle(),
					isDisabledByDisclosurePolicy: { () -> Bool in
						// Whether we should show "Dit bewijs wordt nu niet gebruikt in Nederland."
						switch (state.activeDisclosurePolicyMode, localDisclosurePolicy) {
							case (.exclusive1G, .policy1G),
								(.exclusive3G, .policy1G), // this case is not shown in UI
								(.exclusive3G, .policy3G),
								(.combined1gAnd3g, .policy1G),
								(.combined1gAnd3g, .policy3G):
								return false
								
							case (.exclusive1G, .policy3G):
								return true
						}
					}(),
					validityTexts: validityTextsGenerator(greencards: greencards),
					isLoading: state.isRefreshingStrippen,
					didTapViewQR: { [weak actionHandler] in
						actionHandler?.didTapShowQR(greenCardObjectIDs: greencards.compactMap { $0.id })
					},
					buttonEnabledEvaluator: evaluateEnabledState,
					expiryCountdownEvaluator: { now in

						// Calculate which is the origin with the furthest future expiration:
						var expiringMostDistantlyInFutureOrigin: GreenCard.Origin?
						origins.forEach { origin in
							if origin.expirationTime > (expiringMostDistantlyInFutureOrigin?.expirationTime ?? Date.distantPast) {
								expiringMostDistantlyInFutureOrigin = origin
							}
						}
						
						guard let mostDistantFutureExpiryDate = expiringMostDistantlyInFutureOrigin?.expirationTime,
							  let mostDistantFutureExpiryType = expiringMostDistantlyInFutureOrigin?.type
						else { return nil }
						
						let countdownTimerVisibleThreshold: TimeInterval = mostDistantFutureExpiryType == .test
							? 6 * 60 * 60 // tests have a countdown for last 6 hours
							: 24 * 60 * 60 // everything else has countdown for last 24 hours
						
						guard mostDistantFutureExpiryDate > now && mostDistantFutureExpiryDate < now.addingTimeInterval(countdownTimerVisibleThreshold)
						else { return nil }
 
						let formatter: DateComponentsFormatter = {
							let fiveMinutes: TimeInterval = 5 * 60
							if mostDistantFutureExpiryDate < now.addingTimeInterval(fiveMinutes) {
								// e.g. "4 minuten en 15 seconden"
								return HolderDashboardViewModel.hmsRelativeFormatter
							} else {
								// e.g. "23 uur en 59 minuten"
								return HolderDashboardViewModel.hmRelativeFormatter
							}
						}()

						guard let relativeDateString = formatter.string(
							from: now,
							to: mostDistantFutureExpiryDate.addingTimeInterval(1) // add 1, so that we don't count down to zero
						)
						else { return nil }

						return (L.holderDashboardQrExpiryDatePrefixExpiresIn() + " " + relativeDateString).trimmingCharacters(in: .whitespacesAndNewlines)
					}
				)]

			case .europeanUnion:
				cards += [HolderDashboardViewController.Card.europeanUnionQR(
					title: (self.origins.first?.type.localizedProof ?? L.holderDashboardQrTitle()).capitalizingFirstLetter(),
					stackSize: {
						let minStackSize = 1
						let maxStackSize = 3
						return min(maxStackSize, max(minStackSize, greencards.count))
					}(),
					validityTexts: validityTextsGenerator(greencards: greencards),
					isLoading: state.isRefreshingStrippen,
					didTapViewQR: { [weak actionHandler] in
						actionHandler?.didTapShowQR(greenCardObjectIDs: greencards.compactMap { $0.id })
					},
					buttonEnabledEvaluator: evaluateEnabledState,
					expiryCountdownEvaluator: nil
				)]
		}

		if let error = state.errorForQRCardsMissingCredentials, shouldShowErrorBeneathCard {
			cards += [HolderDashboardViewController.Card.errorMessage(message: error, didTapTryAgain: { [weak actionHandler] in
				actionHandler?.didTapRetryLoadQRCards()
			})]
		}
		
		return cards
	}

	// Returns a closure that, given a Date, will return the groups of text ("ValidityText") that should be shown per-origin on the QR Card.
	private func validityTextsGenerator(greencards: [HolderDashboardViewModel.QRCard.GreenCard]) -> (Date) -> [HolderDashboardViewController.ValidityText] {
		return { now in
			return greencards
				// Make a list of all origins paired with their greencard
				.flatMap { greencard in
					greencard.origins.map { (greencard, $0) }
				}
				// Sort by the customSortIndex, and then by origin eventDate (desc)
				.sorted { lhs, rhs in
					if lhs.1.customSortIndex == rhs.1.customSortIndex {
						return lhs.1.eventDate > rhs.1.eventDate
					}
					return lhs.1.customSortIndex < rhs.1.customSortIndex
				}
				// Map to the ValidityText
				.map { greencard, origin -> HolderDashboardViewController.ValidityText in
					let validityType = QRCard.ValidityType(expiration: origin.expirationTime, validFrom: origin.validFromDate, now: now)
					let first = validityType.text(qrCard: self, greencard: greencard, origin: origin, now: now)
					return first
				}
		}
	}
}

private func localizedOriginsValidOnlyInOtherRegionsMessages(qrCards: [QRCard], thisRegion: QRCodeValidityRegion, now: Date) -> [(originType: QRCodeOriginType, message: String)] {

	// Calculate origins which exist in the other region but are not in this region:
	let originTypesForCurrentRegion = Set(
		qrCards
			.filter { $0.isOfRegion(region: thisRegion) }
			.flatMap { $0.origins }
			.filter {
				$0.isNotYetExpired(now: now)
			}
			.compactMap { $0.type }
	)

	let originTypesForOtherRegion = Set(
		qrCards
			.filter { !$0.isOfRegion(region: thisRegion) }
			.flatMap { $0.origins }
			.filter {
				$0.isNotYetExpired(now: now)
			}
			.compactMap { $0.type }
	)

	let originTypesOnlyInOtherRegion = originTypesForOtherRegion
		.subtracting(originTypesForCurrentRegion)

	// Map it to user messages:
	let userMessages = originTypesOnlyInOtherRegion.compactMap { (originType: QRCodeOriginType) -> (originType: QRCodeOriginType, message: String)? in
		switch (originType, thisRegion) {
			case (.vaccination, .domestic):
				return (originType, L.holderDashboardOriginNotValidInNetherlandsButIsInEUVaccination())
			case (.test, .domestic):
				let containsDomesticVaccinationAssessment = qrCards.contains(where: { $0.origins.contains { $0.type == .vaccinationassessment } })
				guard !containsDomesticVaccinationAssessment else { return nil }
				fallthrough // continue to next case for regular .domestic behavior:
			case (_, .domestic):
				return (originType, L.holderDashboardOriginNotValidInNetherlandsButIsInEU(originType.localizedProof))
			case (.vaccinationassessment, .europeanUnion):
				return (originType, L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title())
			case (_, .europeanUnion):
				return (originType, L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(originType.localizedProof))
		}
	}

	return userMessages
}

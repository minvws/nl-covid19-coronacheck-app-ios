/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

final class TestData {
	
	// Vaccinations
	static let vacP1 = TestPerson(bsn: "999990019", doseIntl: ["1/2"]) // 1 pfizer
	static let vacP2 = TestPerson(bsn: "999990020", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 2 pfizer
	static let vacP3 = TestPerson(bsn: "999990032", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -30) // 3 pfizer
	static let vacP4 = TestPerson(bsn: "999990044", doseNL: 4, doseIntl: ["1/2", "2/2", "3/3", "4/4"], validFromNL: -30) // 4 pfizer
	static let vacJ1 = TestPerson(bsn: "999990081", doseNL: 1, doseIntl: ["1/1"], validFromNL: -2, validUntilNL: 240) // 1 janssen
	static let vacJ2 = TestPerson(bsn: "999990093", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -30) // 2 janssen
	static let vacM1 = TestPerson(bsn: "999990147", doseIntl: ["1/2"]) // 1 moderna
	static let vacM2 = TestPerson(bsn: "999990159", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 2 moderna
	static let vacM3 = TestPerson(bsn: "999990160", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -30) // 3 moderna
	static let vacM4 = TestPerson(bsn: "999990172", doseNL: 4, doseIntl: ["1/2", "2/2", "3/3", "4/4"], validFromNL: -30) // 4 moderna
	static let vacM5 = TestPerson(bsn: "999990184", doseNL: 5, doseIntl: ["1/2", "2/2", "3/3", "4/4", "5/5"], validFromNL: -30) // 5 moderna
	
	// Vaccinations - combinations
	static let vacP1J1 = TestPerson(bsn: "999990196", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -30) // 1 pfizer + 1 janssen
	static let vacP1M1 = TestPerson(bsn: "999990287", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 1 pfizer + 1 moderna
	static let vacP1M2 = TestPerson(bsn: "999990299", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -30) // 1 pfizer + 2 moderna
	static let vacP1M3 = TestPerson(bsn: "999990305", doseNL: 4, doseIntl: ["1/2", "2/2", "3/3", "4/4"], validFromNL: -30) // 1 pfizer + 3 moderna
	static let vacP2M1 = TestPerson(bsn: "999990317", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -30) // 2 pfizer + 1 moderna
	static let vacP2M2 = TestPerson(bsn: "999990329", doseNL: 4, doseIntl: ["1/2", "2/2", "3/3", "4/4"], validFromNL: -30) // 2 pfizer + 2 moderna
	static let vacJ1M1 = TestPerson(bsn: "999990366", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -30) // 1 janssen + 1 moderna
	static let vacJ1M2 = TestPerson(bsn: "999990378", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -30) // 1 janssen + 2 moderna
	static let vacJ2M1 = TestPerson(bsn: "999990408", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -30) // 2 janssen + 1 moderna
	static let vacP2PersonalStatementVacElsewhere = TestPerson(bsn: "999992934", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -30) // 2 pfizer + personal statement + vaccination elsewhere
	static let vacP2MedicalStatementVacElsewhere = TestPerson(bsn: "999992958", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -30) // 2 pfizer + medical statement + vaccination elsewhere
	static let vacP2PersonalStatementPriorEvent = TestPerson(bsn: "999993136", doseNL: 2, doseIntl: ["1/2", "2/2"], validUntilNL: 240) // 2 pfizer + personal statement + prior event
	static let vacP2MedicalStatementPriorEvent = TestPerson(bsn: "999993148", doseNL: 2, doseIntl: ["1/2", "2/2"], validUntilNL: 240) // 2 pfizer + medical statement + prior event
	
	// Vaccinations - personal statement
	static let vacP1PersonalStatement = TestPerson(bsn: "999990457", doseNL: 1, doseIntl: ["1/1"], validFromNL: -16, validUntilNL: 240) // 1 pfizer + personal statement 'recovery'
	static let vacP2PersonalStatement = TestPerson(bsn: "999990469", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -30) // 2 pfizer + personal statement 'recovery'
	static let vacP3PersonalStatement = TestPerson(bsn: "999990470", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -30) // 3 pfizer + personal statement 'recovery'
	static let vacJ1PersonalStatement = TestPerson(bsn: "999990482", doseNL: 1, doseIntl: ["1/1"], validFromNL: -16, validUntilNL: 240) // 1 janssen + personal statement 'recovery'
	static let vacM1PersonalStatement = TestPerson(bsn: "999990524", doseNL: 1, doseIntl: ["1/1"], validFromNL: -16, validUntilNL: 240) // 1 moderna + personal statement 'recovery'
	static let vacM3PersonalStatement = TestPerson(bsn: "999990548", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -30) // 3 moderna + personal statement 'recovery'
	
	// Vaccinations - medical statement
	static let vacP1MedicalStatement = TestPerson(bsn: "999990561", doseNL: 1, doseIntl: ["1/1"], validFromNL: -16, validUntilNL: 240) // 1 pfizer + medical statement 'recovery'
	static let vacP2MedicalStatement = TestPerson(bsn: "999990573", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -30) // 2 pfizer + medical statement 'recovery'
	static let vacM1MedicalStatement = TestPerson(bsn: "999990639", doseNL: 1, doseIntl: ["1/1"], validFromNL: -16, validUntilNL: 240) // 1 moderna + medical statement 'recovery'
	static let vacM3MedicalStatement = TestPerson(bsn: "999990652", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -30) // 3 moderna + medical statement 'recovery'
	
	// Vaccinations - dose numbers
	static let vacP1DoseNumbers = TestPerson(bsn: "999990664", doseNL: 1, doseIntl: ["1/1"], validUntilNL: 240) // 1 pfizer + dose numbers 1/2
	static let vacP2DoseNumbers = TestPerson(bsn: "999990676", doseNL: 3, doseIntl: ["2/2", "3/3"], validFromNL: -30) // 2 pfizer + dose numbers 1/2 en 2/2
	static let vacP3DoseNumbers = TestPerson(bsn: "999990688", doseNL: 5, doseIntl: ["3/3", "4/4", "5/5"], validFromNL: -30) // 3 pfizer + dose numbers 1/2, 2/2, 3/3
	static let vacJ1DoseNumbers = TestPerson(bsn: "999990706", doseNL: 1, doseIntl: ["1/1"], validUntilNL: 240) // 1 janssen + dose numbers 1/1
	static let vacM1DoseNumbers = TestPerson(bsn: "999990755", doseNL: 1, doseIntl: ["1/1"], validUntilNL: 240) // 1 moderna + dose numbers 1/2
	static let vacM3DoseNumbers = TestPerson(bsn: "999990779", doseNL: 5, doseIntl: ["3/3", "4/4", "5/5"], validFromNL: -30) // 3 moderna + dose numbers 1/2, 2/2, 3/3
	
	// Vaccinations - expired (partially)
	static let vacP1Expired = TestPerson(bsn: "999990780", doseIntl: ["1/2"]) // 1 pfizer expired
	static let vacP2Expired = TestPerson(bsn: "999990792", doseIntl: ["1/2", "2/2"]) // 2 pfizer expired
	static let vacP1P1Expired = TestPerson(bsn: "999990809", doseIntl: ["1/2", "2/2"]) // 1 pfizer + 1 pfizer expired
	static let vacJ1Expired = TestPerson(bsn: "999990810", doseIntl: ["1/1"]) // 1 janssen expired
	static let vacJ1J1Expired = TestPerson(bsn: "999990834", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -390) // 1 janssen + 1 janssen expired
	static let vacM1Expired = TestPerson(bsn: "999990858", doseIntl: ["1/2"]) // 1 moderna expired
	static let vacM2Expired = TestPerson(bsn: "999990871", doseIntl: ["1/2", "2/2"]) // 2 moderna expired
	static let vacM1M1Expired = TestPerson(bsn: "999990883", doseIntl: ["1/2", "2/2"]) // 1 moderna + 1 moderna expired
	static let vacP1J1Expired = TestPerson(bsn: "999990895", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -390) // 1 pfizer + 1 janssen expired
	static let vacP1ExpiredJ2 = TestPerson(bsn: "999990901", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -390) // 1 pfizer expired + 2 janssen
	static let vacP1M1Expired = TestPerson(bsn: "999990913", doseIntl: ["1/2", "2/2"]) // 1 pfizer + 1 moderna expired
	static let vacP1ExpiredM2 = TestPerson(bsn: "999990925", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -390) // 1 pfizer expired + 2 moderna
	static let vacJ1ExpiredM2 = TestPerson(bsn: "999990949", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -390) // 1 janssen expired + 2 moderna
	
	// Vaccinations - premature (partially)
	static let vacP1Premature = TestPerson(bsn: "999990950") // 1 pfizer premature
	static let vacP2Premature = TestPerson(bsn: "999990962") // 2 pfizer premature
	static let vacP1P1Premature = TestPerson(bsn: "999990974", doseIntl: ["1/2"]) // 1 pfizer + 1 pfizer premature
	static let vacJ1Today = TestPerson(bsn: "999992983", doseIntl: ["1/1"], validFromNL: 28) // 1 janssen dated today
	static let vacJ1Premature = TestPerson(bsn: "999990986") // 1 janssen premature
	static let vacM2Premature = TestPerson(bsn: "999991036") // 2 moderna premature
	static let vacM1M1Premature = TestPerson(bsn: "999991048", doseIntl: ["1/2"]) // 1 moderna + 1 moderna premature
	static let vacP1M1Premature = TestPerson(bsn: "999991085", doseIntl: ["1/2"]) // 1 pfizer + 1 moderna premature
	static let vacP1PrematureM2 = TestPerson(bsn: "999991097", doseNL: 2, doseIntl: ["1/2", "2/2"]) // 1 pfizer premature + 2 moderna
	static let vacJ1M1Premature = TestPerson(bsn: "999991103", doseNL: 1, doseIntl: ["1/1"]) // 1 janssen + 1 moderna premature
	static let vacJ1PrematureM2 = TestPerson(bsn: "999991115", doseNL: 2, doseIntl: ["1/2", "2/2"]) // 1 janssen premature + 2 moderna
	
	// Vaccinations - error states
	static let vacNoVaccination = TestPerson(bsn: "999991127") // no vaccination
	static let vacP2SameDate = TestPerson(bsn: "999991139", doseNL: 1, doseIntl: ["1/2"], validFromNL: -16, validUntilNL: 240) // 2 pfizer same date
	static let vacP1J1SameDate = TestPerson(bsn: "999991140", doseNL: 1, doseIntl: ["1/1"], validFromNL: -2, validUntilNL: 240) // 1 pfizer + 1 janssen same date
	static let vacP1M1SameDate = TestPerson(bsn: "999991164", doseIntl: ["1/2"]) // 1 pfizer + 1 moderna same date
	static let vacP2EmptyFirstName = TestPerson(bsn: "999991176", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 2 pfizer empty first name
	static let vacP2EmptyLastName = TestPerson(bsn: "999991188", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 2 pfizer empty last name
	static let vacP2BirthdateXXXX = TestPerson(bsn: "999991206") // 2 pfizer birthdate XX-XX
	static let vacP2BirthdateXX01 = TestPerson(bsn: "999993008", doseNL: 2, validUntilNL: 240) // 2 pfizer birthdate XX-01
	static let vacP2BirthdateJAN01 = TestPerson(bsn: "999991231") // 2 pfizer birthdate JAN-01
	static let vacP2Birthdate0101 = TestPerson(bsn: "999991243") // 2 pfizer birthdate 0101
	
	// Vaccinations - event matching
	static let vacP2DifferentFirstName = TestPerson(bsn: "999991255", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 2 pfizer different first name
	static let vacP2DifferentLastName = TestPerson(bsn: "999991267", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 2 pfizer different last name
	static let vacP2DifferentBirthDay = TestPerson(bsn: "999991279", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 2 pfizer different birth day
	static let vacP2DifferentBirthMonth = TestPerson(bsn: "999993021", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 2 pfizer different birth month
	static let vacP2DifferentBirthYear = TestPerson(bsn: "999991292", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // 2 pfizer different birth year
	
	// Positive tests (and combinations)
	static let posPcr = TestPerson(bsn: "999993033") // Positive PCR (NAAT)
	static let posPcrP1 = TestPerson(bsn: "999991346", doseIntl: ["1/2"]) // Positive PCR (NAAT) + 1 pfizer
	static let posPcrP2 = TestPerson(bsn: "999991358", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -60, validUntilNL: 210) // Positive PCR (NAAT) + 2 pfizer
	static let posPcrP3 = TestPerson(bsn: "999991383", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -60) // Positive PCR (NAAT) + 3 pfizer
	static let posPcrJ1 = TestPerson(bsn: "999991395", doseNL: 1, doseIntl: ["1/1"], validFromNL: -2, validUntilNL: 210) // Positive PCR (NAAT) + 1 janssen
	static let posPcrJ2 = TestPerson(bsn: "999991401", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -60) // Positive PCR (NAAT) + 2 janssen
	static let posPcrJ3 = TestPerson(bsn: "999991413", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -60) // Positive PCR (NAAT) + 3 janssen
	static let posPcrP1J1 = TestPerson(bsn: "999991425", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -60) // Positive PCR (NAAT) + 1 pfizer + 1 janssen
	static let posPcrP2J1 = TestPerson(bsn: "999991437", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -60) // Positive PCR (NAAT) + 2 pfizer + 1 janssen
	static let posPcrP1M1 = TestPerson(bsn: "999991449", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -60, validUntilNL: 210) // Positive PCR (NAAT) + 1 pfizer + 1 moderna
	static let posPcrP2M1 = TestPerson(bsn: "999991450", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -60) // Positive PCR (NAAT) + 2 pfizer + 1 moderna
	static let posRat = TestPerson(bsn: "999991310") // Positive Sneltest (RAT)
	static let posRatP1 = TestPerson(bsn: "999991462", doseIntl: ["1/2"]) // Positive Sneltest (RAT) + 1 pfizer
	static let posRatP2 = TestPerson(bsn: "999991474", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 150) // Positive Sneltest (RAT) + 2 pfizer
	static let posRatP3 = TestPerson(bsn: "999991486", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -60) // Positive Sneltest (RAT) + 3 pfizer
	static let posRatJ1 = TestPerson(bsn: "999991498", doseNL: 1, doseIntl: ["1/1"], validFromNL: -2, validUntilNL: 150) // Positive Sneltest (RAT) + 1 janssen
	static let posRatJ2 = TestPerson(bsn: "999991504", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -60) // Positive Sneltest (RAT) + 2 janssen
	static let posRatJ3 = TestPerson(bsn: "999991516", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -60) // Positive Sneltest (RAT) + 3 janssen
	static let posRatP1J1 = TestPerson(bsn: "999991553", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -60) // Positive Sneltest (RAT) + 1 pfizer + 1 janssen
	static let posRatP2J1 = TestPerson(bsn: "999991565", doseNL: 3, doseIntl: ["1/1", "2/1", "3/1"], validFromNL: -60) // Positive Sneltest (RAT) + 2 pfizer + 1 janssen
	static let posRatP1M1 = TestPerson(bsn: "999991577", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -60, validUntilNL: 210) // Positive Sneltest (RAT) + 1 pfizer + 1 moderna
	static let posRatP2M1 = TestPerson(bsn: "999991589", doseNL: 3, doseIntl: ["1/2", "2/2", "3/3"], validFromNL: -60) // Positive Sneltest (RAT) + 2 pfizer + 1 moderna
	static let posBreathalyzer = TestPerson(bsn: "999991322") // Positive Breathalyzer
	static let posBreathalyzerP1 = TestPerson(bsn: "999991590", doseIntl: ["1/2"]) // Positive Breathalyzer + 1 pfizer
	static let posAgob = TestPerson(bsn: "999991334") // Positive AGOB
	static let posAgobP1 = TestPerson(bsn: "999991747", doseIntl: ["1/2"]) // Positive AGOB + 1 pfizer
	static let posAgobP2 = TestPerson(bsn: "999991759", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 210) // Positive AGOB + 2 pfizer
	
	// Positive tests before vaccinations
	static let posPcrBeforeP1 = TestPerson(bsn: "999993495", doseNL: 1, doseIntl: ["1/1"], validFromNL: -30, validUntilNL: 240) // Positive PCR (NAAT) before 1 pfizer
	static let posPcrBeforeP2 = TestPerson(bsn: "999993203", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -30) // Positive PCR (NAAT) before 2 pfizer
	static let posPcrBeforeJ1 = TestPerson(bsn: "999993215", doseNL: 1, doseIntl: ["1/1"], validFromNL: -30, validUntilNL: 240) // Positive PCR (NAAT) before 1 janssen
	static let posPcrBeforeM2 = TestPerson(bsn: "999993227", doseNL: 2, doseIntl: ["1/1", "2/1"], validFromNL: -30) // Positive PCR (NAAT) before 2 moderna
	
	// Positive tests - expired
	static let posExpiredPcr = TestPerson(bsn: "999991851") // Positive PCR (NAAT) expired
	static let posExpiredRat = TestPerson(bsn: "999991863") // Positive Sneltest (RAT) expired
	static let posExpiredAgob = TestPerson(bsn: "999991887") // Positive AGOB expired
	
	// Positive tests - premature
	static let posPrematurePcr = TestPerson(bsn: "999991905") // Positive PCR (NAAT) premature
	static let posPrematureRat = TestPerson(bsn: "999991917") // Positive Sneltest (RAT) premature
	static let posPrematureAgob = TestPerson(bsn: "999991930") // Positive AGOB premature
	
	// Positive tests - event matching
	static let posPcrDifferentFirstName = TestPerson(bsn: "999991942") // Positive PCR (NAAT) different first name
	static let posPcrDifferentLastName = TestPerson(bsn: "999991954") // Positive PCR (NAAT) different last name
	static let posPcrDifferentBirthdate = TestPerson(bsn: "999991966") // Positive PCR (NAAT) different birthdate
	static let posPcrDifferentBirthDay = TestPerson(bsn: "999991978") // Positive PCR (NAAT) different birth day
	static let posPcrDifferentBirthMonth = TestPerson(bsn: "999991991") // Positive PCR (NAAT) different birth month
	
	// Negative tests (and combinations)
	static let negPcr = TestPerson(bsn: "999992004") // Negative PCR (NAAT)
	static let negPcrP1 = TestPerson(bsn: "999992065", doseIntl: ["1/2"]) // Negative PCR (NAAT) + 1 pfizer
	static let negRat = TestPerson(bsn: "999992016") // Negative Sneltest (RAT)
	static let negRatP1 = TestPerson(bsn: "999992168", doseIntl: ["1/2"]) // Negative Sneltest (RAT) + 1 pfizer
	static let negAgob = TestPerson(bsn: "999992041") // Negative AGOB
	static let negAgobP1 = TestPerson(bsn: "999992429", doseIntl: ["1/2"]) // Negative AGOB + 1 pfizer
	
	// Negative tests - expired
	static let negExpiredPcr = TestPerson(bsn: "999992545") // Negative PCR (NAAT) expired
	static let negExpiredRat = TestPerson(bsn: "999992557") // Negative Sneltest (RAT) expired
	static let negExpiredAgob = TestPerson(bsn: "999992570") // Negative AGOB expired
	
	// Negative tests - premature
	static let negPrematurePcr = TestPerson(bsn: "999992582") // Negative PCR (NAAT) premature
	static let negPrematureRat = TestPerson(bsn: "999992594") // Negative Sneltest (RAT) premature
	static let negPrematureAgob = TestPerson(bsn: "999992612") // Negative AGOB premature
	
	// Negative tests - event matching
	static let negPcrDifferentFirstName = TestPerson(bsn: "999992624") // Negative PCR (NAAT) different first name
	static let negPcrDifferentLastName = TestPerson(bsn: "999992636") // Negative PCR (NAAT) different last name
	static let negPcrDifferentBirthdate = TestPerson(bsn: "999992648") // Negative PCR (NAAT) different birthdate
	static let negPcrDifferentBirthDay = TestPerson(bsn: "999992661") // Negative PCR (NAAT) different birth day
	static let negPcrDifferentBirthMonth = TestPerson(bsn: "999992685") // Negative PCR (NAAT) different birth month
	
	// Encoding
	static let encodingLatin = TestPerson(bsn: "999992697", name: "Geer, Corrie") // Latin
	static let encodingLatinDiacritic = TestPerson(bsn: "999992703", name: "T.Śar ŃĆ ĹāÑ ŤÙmön ĊéŴÀŅŇĩ Ļl'ÁÚŘŠĎÉ Pomme-d' Or ĽÒÓĢÛŨ, Ŗî Ãō Øū Ŋÿ Ği ŢžŰŲ ŜŞőĠĪ Ŷŵ Ĉŷ") // Latin diacritic
	static let encodingArabic = TestPerson(bsn: "999992715", name: "⁨بوير, بوب⁩") // Arabic
	static let encodingHebrew = TestPerson(bsn: "999992727", name: "⁨בורד, בוב⁩") // Hebrew
	static let encodingChinese = TestPerson(bsn: "999992739", name: "吹牛, 鲍勃") // Chinese
	static let encodingGreek = TestPerson(bsn: "999992740", name: "οικοδόμος, Ἄκαστος") // Greek
	static let encodingCyrillic = TestPerson(bsn: "999992752", name: "строитель, бобов") // Cyrillic
	static let encodingEmoji = TestPerson(bsn: "999992764", name: "😀😃, ↗↩↩↫↹🔙⇥⇌") // Emoji
	static let encodingLongStrings = TestPerson(bsn: "999992788", name: "rjnmngevcjgsnicomdzzzguszmfcelknwscoirscjhyfauwsffyhwlaiqfnoctcjbsihyzvxehksjoehzrkadocswofathihsbwuhvrxetuswcybwrkkcofkybgjbdyn rjnmngevcjgsnicomdzzzguszmfcelknwscoirscjhyfauwsffyhwlaiqfnoctcjbsihyzvxehksjoehzrkadocswofathihsbwuhvrxetuswcybwrkkcofkybgjbdyn, rjnmngevcjgsnicomdzzzguszmfcelknwscoirscjhyfauwsffyhwlaiqfnoctcjbsihyzvxehksjoehzrkadocswofathihsbwuhvrxetuswcybwrkkcofkybgjbdyn") // More than 128 characters in all fields
	static let encodingLongNames = TestPerson(bsn: "999992806", name: "qhxosdaetanrazewwepgqghihpxaruqkpwhkctspdtjeky, qhxosdaetanrazewwepgqghihpxaruqkpwhkctspdtjeky") // Long first name and last name (96 chars)
	
	// Vaccination - Null or empty information
	static let vacP1NullPersonalStatement = TestPerson(bsn: "999992818", doseIntl: ["1/2"]) // 1 pfizer + personal statement = null
	static let vacP1NullMedicalStatement = TestPerson(bsn: "999992831", doseIntl: ["1/2"]) // 1 pfizer + medical statement = null
	static let vacP1NullFirstName = TestPerson(bsn: "999992843", doseIntl: ["1/2"]) // 1 pfizer + first name = null
	static let vacP1NullLastName = TestPerson(bsn: "999992855", doseIntl: ["1/2"]) // 1 pfizer + last name = null
	static let vacP1NullBirthdate = TestPerson(bsn: "999992867", doseIntl: ["1/2"]) // 1 pfizer + birthdate = null
	static let vacP1EmptyPersonalStatement = TestPerson(bsn: "999992879", doseIntl: ["1/2"]) // 1 pfizer + personal statement = empty
	static let vacP1EmptyMedicalStatement = TestPerson(bsn: "999992880", doseIntl: ["1/2"]) // 1 pfizer + medical statement = empty
	static let vacP1EmptyFirstName = TestPerson(bsn: "999992892", doseIntl: ["1/2"]) // 1 pfizer + first name = empty
	static let vacP1EmptyLastName = TestPerson(bsn: "999992909", doseIntl: ["1/2"]) // 1 pfizer + last name = empty
	static let vacP1EmptyBirthdate = TestPerson(bsn: "999992910", doseIntl: ["1/2"]) // 1 pfizer + birthdate = empty
	
	// Miscellaneous
	static let miscP1Positive = TestPerson(bsn: "999992971", doseNL: 1, doseIntl: ["1/2"], validFromNL: -16, validUntilNL: 240) // positive test after 1 pfizer
	static let miscP2PosPcrNegPcr = TestPerson(bsn: "999991772", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -90, validUntilNL: 180) // 2 pfizer + positive/negative PCR (NAAT)
	
	// Vaccinations - almost 18
	static let almost18Is17y8mWithP2LastDose1M = TestPerson(bsn: "999993422", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16) // Almost 18: 2 pfizer, 4 months before 18, last dose 1 month ago
	static let almost18Is17y10mWithP2LastDose1M = TestPerson(bsn: "999993434", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -16, validUntilNL: 240) // Almost 18: 2 pfizer, 2 months before 18, last dose 1 month ago
	static let almost18Is17y10mWithP2LastDose9M = TestPerson(bsn: "999993446", doseNL: 2, doseIntl: ["1/2", "2/2"], validFromNL: -256, validUntilNL: 51, birthDate: "2004-04-01") // Almost 18: 2 pfizer, 2 months before 18, last dose 9 months ago
	static let almost18Is17y8mWithJ1LastDose1M = TestPerson(bsn: "999993458", doseNL: 1, doseIntl: ["1/1"], validFromNL: -2) // Almost 18: 1 janssen, 4 months before 18, last dose 1 month ago
	static let almost18Is17y10mWithJ1LastDose1M = TestPerson(bsn: "999993471", doseNL: 1, doseIntl: ["1/1"], validFromNL: -30, validUntilNL: 240) // Almost 18: 1 janssen, 2 months before 18, last dose 1 month ago
	static let almost18Is17y10mWithJ1LastDose9M = TestPerson(bsn: "999993483", doseNL: 1, doseIntl: ["1/1"], validFromNL: -242, validUntilNL: 51, birthDate: "2004-04-01") // Almost 18: 1 janssen, 2 months before 18, last dose 9 months ago
}

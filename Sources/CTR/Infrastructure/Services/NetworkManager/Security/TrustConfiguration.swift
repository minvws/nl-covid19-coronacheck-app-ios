/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

struct SigningCertificate {

	/// The name of the certificate
	let name: String

	/// The certificate
	let certificate: String

	/// The required common name
	let commonName: String?

	/// The required authority Key
	let authorityKeyIdentifier: Data?

	/// The required subject key
	let subjectKeyIdentifier: Data?

	/// The serial number
	let rootSerial: UInt64?

	/// Get the certificate data
	/// - Returns: the certificate data
	func getCertificateData() -> Data {

		return Data(certificate.utf8)
	}
}

struct TrustConfiguration {

	static let sdNRootCAG3Certificate = SigningCertificate(
		name: "Staat der Nederlanden Root CA - G3",
		certificate: TrustConfiguration.sdNRootCAG3String,
		commonName: "coronatester.nl",
		authorityKeyIdentifier: nil,
		subjectKeyIdentifier: Data([0x04, 0x14, /* keyID starts here: */ 0x54, 0xAD, 0xFA, 0xC7, 0x92, 0x57, 0xAE, 0xCA, 0x35, 0x9C, 0x2E, 0x12, 0xFB, 0xE4, 0xBA, 0x5D, 0x20, 0xDC, 0x94, 0x57]),
		rootSerial: 10003001
	)

	static let sdNEVRootCACertificate = SigningCertificate(
		name: "Staat der Nederlanden EV Root CA",
		certificate: TrustConfiguration.sdNEVRootCAString,
		commonName: "coronatester.nl",
		authorityKeyIdentifier: Data([0x04, 0x14, /* keyID starts here: */ 0x08, 0x4A, 0xAA, 0xBB, 0x99, 0x24, 0x6F, 0xBE, 0x5B, 0x07, 0xF1, 0xA5, 0x8A, 0x99, 0x5B, 0x2D, 0x47, 0xEF, 0xB9, 0x3C]),
		subjectKeyIdentifier: Data([0x04, 0x14, /* keyID starts here: */ 0xFE, 0xAB, 0x00, 0x90, 0x98, 0x9E, 0x24, 0xFC, 0xA9, 0xCC, 0x1A, 0x8A, 0xFB, 0x27, 0xB8, 0xBF, 0x30, 0x6E, 0xA8, 0x3B]),
		rootSerial: 10000013
	)

	static let sdNPrivateRootCertificate = SigningCertificate(
		name: "Staat der Nederlanden Private Root CA - G1",
		certificate: TrustConfiguration.sdNPrivateRootString,
		commonName: "coronatester.nl",
		authorityKeyIdentifier: nil,
		subjectKeyIdentifier: Data([0x04, 0x14, /* keyID starts here: */ 0x2A, 0xFD, 0xB9, 0x2B, 0x1E, 0xFA, 0xC3, 0x84, 0x87, 0x06, 0xDB, 0x81, 0xFF, 0x86, 0x97, 0x75, 0x0D, 0xEB, 0x01, 0x8B]),
		rootSerial: 10004001
	)

	static let commonNameContent = ".coronacheck.nl"

	static var sdNRootCAG3: Data {
		return Data(TrustConfiguration.sdNRootCAG3String.utf8)
	}

	static var sdNEVRootCA: Data {
		return Data(TrustConfiguration.sdNEVRootCAString.utf8)
	}

	static var sdNPrivateRoot: Data {
		return Data(TrustConfiguration.sdNPrivateRootString.utf8)
	}

	static let sdNRootCAG3String = """
-----BEGIN CERTIFICATE-----
MIIFdDCCA1ygAwIBAgIEAJiiOTANBgkqhkiG9w0BAQsFADBaMQswCQYDVQQGEwJO
TDEeMBwGA1UECgwVU3RhYXQgZGVyIE5lZGVybGFuZGVuMSswKQYDVQQDDCJTdGFh
dCBkZXIgTmVkZXJsYW5kZW4gUm9vdCBDQSAtIEczMB4XDTEzMTExNDExMjg0MloX
DTI4MTExMzIzMDAwMFowWjELMAkGA1UEBhMCTkwxHjAcBgNVBAoMFVN0YWF0IGRl
ciBOZWRlcmxhbmRlbjErMCkGA1UEAwwiU3RhYXQgZGVyIE5lZGVybGFuZGVuIFJv
b3QgQ0EgLSBHMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL4yolQP
cPssXFnrbMSkUeiFKrPMSjTysF/zDsccPVMeiAho2G89rcKezIJnByeHaHE6n3WW
IkYFsO2tx1ueKt6c/DrGlaf1F2cY5y9JCAxcz+bMNO14+1Cx3Gsy8KL+tjzk7FqX
xz8ecAgwoNzFs21v0IJyEavSgWhZghe3eJJg+szeP4TrjTgzkApyI/o1zCZxMdFy
KJLZWyNtZrVtB0LrpjPOktvA9mxjeM3KTj215VKb8b475lRgsGYeCasH/lSJEULR
9yS6YHgamPfJEf0WwTUaVHXvQ9Plrk7O53vDxk5hUUurmkVLoR9BvUhTFXFkC4az
5S6+zqQbwSmEorXLCCN2QyIkHxcE1G6cxvx/K2Ya7Irl1s9N9WMJtxU51nus6+N8
6U78dULI7ViVDAZCopz35HCz33JvWjdAidiFpNfxC95DGdRKWCyMijmev4SH8RY7
Ngzp07TKbBlBUgmhHbBqv4LvcFEhMtwFdozL92TkA1CvjJFnq8Xy7ljY3r735zHP
bMk7ccHViLVlvMDoFxcHErVc0qsgk7TmgoNwNsXNo42ti+yjwUOH5kPiNL6VizXt
BznaqB16nzaeErAMZRKQFWDZJkBE41ZgpRDUajz9QdwOWke275dhdU/Z/seyHdTt
XUmzqWrLZoQT1Vyg3N9udwbRcXXIV2+vD3dbAgMBAAGjQjBAMA8GA1UdEwEB/wQF
MAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBRUrfrHkleuyjWcLhL75Lpd
INyUVzANBgkqhkiG9w0BAQsFAAOCAgEAMJmdBTLIXg47mAE6iqTnB/d6+Oea31BD
U5cqPco8R5gu4RV78ZLzYdqQJRZlwJ9UXQ4DO1t3ApyEtg2YXzTdO2PCwyiBwpwp
LiniyMMB8jPqKqrMCQj3ZWfGzd/TtiunvczRDnBfuCPRy5FOCvTIeuXZYzbB1N/8
Ipf3YF3qKS9Ysr1YvY2WTxB1v0h7PVGHoTx0IsL8B3+A3MSs/mrBcDCw6Y5p4ixp
gZQJut3+TcCDjJRYwEYgr5wfAvg1VUkvRtTA8KCWAg8zxXHzniN9lLf9OtMJgwYh
/WA9rjLA0u6NpvDntIJ8CsxwyXmA+P5M9zWEGYox+wrZ13+b8KKaa8MFSu1BYBQw
0aoRQm7TIwIEC8Zl3d1Sd9qBa7Ko+gE4uZbqKmxnl4mUnrzhVNXkanjvSr0rmj1A
fsbAddJu+2gw7OyLnflJNZoaLNmzlTnVHpL3prllL+U9bTpITAjc5CgSKL59NVzq
4BZ+Extq1z7XnvwtdbLBFNUjA9tbbws+eC8N3jONFrdI54OagQ97wUNNVQQXOEpR
1VmiiXTTn74eS9fGbbeIJG9gkaSChVtWQbzQRKtqE77RLFi3EjNYsjdj3BP1lB0/
QFH1T/U67cjF68IeHRaVesd+QnGTbksVtzDfqu1XhUisHWrdOWnk4Xl4vs4Fv6EM
94B7IWcnMFk=
-----END CERTIFICATE-----
"""

	static let sdNEVRootCAString = """
-----BEGIN CERTIFICATE-----
MIIFcDCCA1igAwIBAgIEAJiWjTANBgkqhkiG9w0BAQsFADBYMQswCQYDVQQGEwJO
TDEeMBwGA1UECgwVU3RhYXQgZGVyIE5lZGVybGFuZGVuMSkwJwYDVQQDDCBTdGFh
dCBkZXIgTmVkZXJsYW5kZW4gRVYgUm9vdCBDQTAeFw0xMDEyMDgxMTE5MjlaFw0y
MjEyMDgxMTEwMjhaMFgxCzAJBgNVBAYTAk5MMR4wHAYDVQQKDBVTdGFhdCBkZXIg
TmVkZXJsYW5kZW4xKTAnBgNVBAMMIFN0YWF0IGRlciBOZWRlcmxhbmRlbiBFViBS
b290IENBMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA48d+ifkkSzrS
M4M1LGns3Amk41GoJSt5uAg94JG6hIXGhaTK5skuU6TJJB79VWZxXSzFYGgEt9nC
UiY4iKTWO0Cmws0/zZiTs1QUWJZV1VD+hq2kY39ch/aO5ieSZxeSAgMs3NZmdO3d
Z//BYY1jTw+bbRcwJu+r0h8QoPnFfxZpgQNH7R5ojXKhTbImxrpsX23Wr9GxE46p
rfNeaXUmGD5BKyF/7otdBwadQ8QpCiv8Kj6GyzyDOvnJDdrFmeK8eEEzduG/L13l
pJhQDBXd4Pqcfzho0LKmeqfRMb1+ilgnQ7O6M5HTp5gVXJrm0w912fxBmJc+qiXb
j5IusHsMX/FjqTf5m3VpTCgmJdrV8hJwRVXj33NeN/UhbJCONVrJ0yPr08C+eKxC
KFhmpUZtcALXEPlLVPxdhkqHz3/KRawRWrUgUY0viEeXOcDPusBCAUCZSCELa6fS
/ZbV0b5GnUngC6agIk440ME8MLxwjyx1zNDFjFE7PZQIZCZhfbnDZY8UnCHQqv0X
cgOPvZuM5l5Tnrmd74K74bzickFbIZTTRTeU0d8JOV3nI6qaHcptqAqGhYqCvkIH
1vI4gnPah1vlPNOePqc7nvQDs/nxfRN0Av+7oeX6AHkcpmZBiFxgV6YuCcS6/ZrP
px9Aw7vMWgpVSzs4dlG4Y4uElBbmVvMCAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB
/zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFP6rAJCYniT8qcwaivsnuL8wbqg7
MA0GCSqGSIb3DQEBCwUAA4ICAQDPdyxuVr5Os7aEAJSrR8kN0nbHhp8dB9O2tLsI
eK9p0gtJ3jPFrK3CiAJ9Brc1AsFgyb/E6JTe1NOpEyVa/m6irn0F3H3zbPB+po3u
2dfOWBfoqSmuc0iH55vKbimhZF8ZE/euBhD/UcabTVUlT5OZEAFTdfETzsemQUHS
v4ilf0X8rLiltTMMgsT7B/Zq5SWEXwbKwYY5EdtYzXc7LMJMD16a4/CrPmEbUCTC
wPTxGfARKbalGAKb12NMcIxHowNDXLldRqANb/9Zjr7dn3LDWyvfjFvO5QxGbJKy
CqNMVEIYFRIYvdr8unRu/8G2oGTYqV9Vrp9canaW2HNnh/tNf1zuacpzEPuKqf2e
vTY4SUmH9A4U8OmHuD+nT3pajnnUk+S7aFKErGzp85hwVXIy+TSrK0m1zSBi5Dp6
Z2Orltxtrpfs/J92VoguZs9btsmksNcFuuEnL5O7Jiqik7Ab846+HUCjuTaPPoIa
Gl6I6lD4WeKDRikL40Rc4ZW2aZCaFG+XroHPaO+Zmr615+F/+PoTRxZMzG0IQOeL
eG9QgkRQP2YGiqtDhFZKDyAthg710tvSeopLzaXoTvFeJiUBWSOgftL2fiFX1ye8
FVdMpEbB4IMeDExNH08GGeL5qPQ6gqGyeUN51q1veieQA6TqJIc/2b3Z6fJfUEkc
7uzXLg==
-----END CERTIFICATE-----
"""

	static let sdNPrivateRootString = """
-----BEGIN CERTIFICATE-----
MIIFhDCCA2ygAwIBAgIEAJimITANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJO
TDEeMBwGA1UECgwVU3RhYXQgZGVyIE5lZGVybGFuZGVuMTMwMQYDVQQDDCpTdGFh
dCBkZXIgTmVkZXJsYW5kZW4gUHJpdmF0ZSBSb290IENBIC0gRzEwHhcNMTMxMTE0
MTM0ODU1WhcNMjgxMTEzMjMwMDAwWjBiMQswCQYDVQQGEwJOTDEeMBwGA1UECgwV
U3RhYXQgZGVyIE5lZGVybGFuZGVuMTMwMQYDVQQDDCpTdGFhdCBkZXIgTmVkZXJs
YW5kZW4gUHJpdmF0ZSBSb290IENBIC0gRzEwggIiMA0GCSqGSIb3DQEBAQUAA4IC
DwAwggIKAoICAQDaIMh56ynwnEhE7Ey54KpX5j1XDoxbHDCgXctute55RjmG2hy6
fuq++q/dCSsj38Pi/KYn/PN13EF05k39IRvakb0AQNVyHifNKXfta6Tzi5QcM4BK
09DB4Ckb6TdZTNUtWyEcAtRblYaVSQ4Xr5QODNqu2FGQucraVXqCIx81azlOE2Jb
Zli9AZKn94pP57A11dUYhxMsh70YosJEKVB8Ue4ROksHhb/nnOISG+2y9FD5M8u8
jYhp00TGZGVu5z0IFgtqX0i8GmrH0ub9AWjf/iU4MWjGVRSq0cwUHEeKRj/UD9a8
xIEn9TxIfYj+6+s4tn9dW/4PV5jc6iGJx6ExTPfOR7VHpxS4XujrZb5Ba/+oj/ON
dOfR0JSm2itCytbtjQBBL0oocIIqaqOna1cufHkcn9VleF7Zvz/8njQIpAU4J4nJ
4pE5pQ3k4ORAGNnq5R9hAqqUQGDlo3Uj8PBou0nPzQ7JNgGkN+my/lGr4rceUNK/
8CoGnYFUH+UyFtJkvlLlEkb688/IdNdGgY+vuXCAB6xfKlJjAGChFUBb6swbNeNc
tVEdUj7Weg4Jt5gXu78C2mjs9x5lcHOgMO4ZmvYJ3Ejp4k3nNa45HOIVkYrfQrrB
HzBhR0BuReAagurcbtUjJFd7BtufGVLfU3CUn1l6u3/9eG4DGH6pq+dSKQIDAQAB
o0IwQDAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIBBjAdBgNVHQ4EFgQU
Kv25Kx76w4SHBtuB/4aXdQ3rAYswDQYJKoZIhvcNAQELBQADggIBAEvpmXMOOKdQ
wUPysrsdIkGJUFF+dvmsJDiOuAqV0A1nNTooL3esvDLEZAWZwKTOwRomnHzeCfS/
QxRKTkVX21pfrHf9ufDKykpzjl9uAILTS76FJ6//R0RTIPMrzknQpG2fCLR5DFEb
HWU/jWAxGmncfx6HQYl/azHaWbv0dhZOUjPdkGAQ6EPvHcyNU9yMkETdw0X6ioxq
zMwkGM893oBrMmtduiqIf3/H6HTXoRKAc+/DXZIq/pAc6eVMa6x43kokluaam9L7
8yDrlHbGd2VYAr/HZ0TjDZTtI2t2/ySTb7JjC8wL8rSqxYmLpNrnhZzPW87sl2OC
FC3re3ZhtJkIHNP85jj1gqewTC7DCW6llZdB3hBzfHWby0EX2RlcwgaMfNBEV5U0
IogccdXV+S6zWK4F+yBr0sXUrdbdMFu+g3I9CbXxt0q4eVJtoaun4M2Z+bZMqZvy
9FryBdSfhpgmJqwFz2luOhPOVCblCPhLrUeewrvuBXoZQWt1ZjuHfwJZ1dgjszVE
qwY9S0SdqCg2ZlL9s3vDIrrd3wLWrcHLQMd9gwsppNv9c7JfIJdlcZLTmF9EuL6e
CvVVrqBVqLHjva4erqYol6K/jbSfUtRCy8IlFU7LYu1KLehZKYvj3vekj3Cn08Aq
ljr/Q8Pw+OfUZTzKg4PVDQVfFqKtyosv
-----END CERTIFICATE-----
"""
}

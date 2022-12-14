/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import HTTPSecurity

struct TrustConfiguration {

	static let sdNRootCAG3Certificate = SigningCertificate(
		name: "Staat der Nederlanden Root CA - G3",
		certificate: TrustConfiguration.sdNRootCAG3String,
		commonName: ".coronatester.nl",
		authorityKeyIdentifier: nil,
		subjectKeyIdentifier: Data([0x04, 0x14, /* keyID starts here: */ 0x54, 0xAD, 0xFA, 0xC7, 0x92, 0x57, 0xAE, 0xCA, 0x35, 0x9C, 0x2E, 0x12, 0xFB, 0xE4, 0xBA, 0x5D, 0x20, 0xDC, 0x94, 0x57]),
		rootSerial: 10003001
	)

	static let sdNPrivateRootCertificate = SigningCertificate(
		name: "Staat der Nederlanden Private Root CA - G1",
		certificate: TrustConfiguration.sdNPrivateRootString,
		commonName: ".coronatester.nl",
		authorityKeyIdentifier: nil,
		subjectKeyIdentifier: Data([0x04, 0x14, /* keyID starts here: */ 0x2A, 0xFD, 0xB9, 0x2B, 0x1E, 0xFA, 0xC3, 0x84, 0x87, 0x06, 0xDB, 0x81, 0xFF, 0x86, 0x97, 0x75, 0x0D, 0xEB, 0x01, 0x8B]),
		rootSerial: 10004001
	)

	static let commonNameContent = ".coronacheck.nl"

	static var sdNRootCAG3: Data {
		return Data(TrustConfiguration.sdNRootCAG3String.utf8)
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

// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CryptoCore",
	products: [
		.library(name: "CryptoCore", targets: ["mobilecore"])
	],
	dependencies: [],
	targets: [
		.binaryTarget(name: "mobilecore", path: "Frameworks/mobilecore.xcframework")
	]
)

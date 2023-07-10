// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CoronaCheckTest",
	products: [
		.library(
			name: "CoronaCheckTest",
			targets: ["CoronaCheckTest"]
		)
	],
	dependencies: [
		// Internal:
		.package(name: "TestingShared", path: "../TestingShared"),
		
		// Testing:
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.11.0"),
		.package(url: "https://github.com/Quick/Nimble", from: "10.0.0")
	],
	targets: [
		.target(
			name: "CoronaCheckTest",
			dependencies: [
				.product(name: "TestingShared", package: "TestingShared"),
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
				.product(name: "Nimble", package: "Nimble")
			]
		)
	]
)

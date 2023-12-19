// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CoronaCheckFoundation",
	products: [
		.library(
			name: "CoronaCheckFoundation",
			targets: ["CoronaCheckFoundation"]
		)
	],
	dependencies: [
		// Internal:
		.package(name: "Persistence", path: "../Persistence"),
		.package(name: "Shared", path: "../Shared"),
	],
	targets: [
		.target(
			name: "CoronaCheckFoundation",
			dependencies: [
				.product(name: "Persistence", package: "Persistence"),
				.product(name: "Shared", package: "Shared")
			]
		)
	]
)

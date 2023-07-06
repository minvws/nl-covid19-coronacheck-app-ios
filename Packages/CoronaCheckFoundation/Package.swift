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
		.package(name: "Managers", path: "../Managers"),
		.package(name: "Models", path: "../Models"),
		.package(name: "Persistence", path: "../Persistence"),
		.package(name: "Shared", path: "../Shared")
	],
	targets: [
		.target(
			name: "CoronaCheckFoundation",
			dependencies: [
				.product(name: "Managers", package: "Managers"),
				.product(name: "Models", package: "Models"),
				.product(name: "Persistence", package: "Persistence"),
				.product(name: "Shared", package: "Shared")
			]
		)
	]
)

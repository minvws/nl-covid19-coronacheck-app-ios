// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CoronaCheckUI",
	products: [
		.library(
			name: "CoronaCheckUI",
			targets: ["CoronaCheckUI"]),
	],
	dependencies: [
		.package(name: "Shared", path: "../Shared"),
		.package(name: "Resources", path: "../Resources"),
		.package(name: "ReusableViews", path: "../ReusableViews")
	],
	targets: [
		.target(
			name: "CoronaCheckUI",
			dependencies: [
				.product(name: "Resources", package: "Resources"),
				.product(name: "ReusableViews", package: "ReusableViews"),
				.product(name: "Shared", package: "Shared")
			])
	]
)

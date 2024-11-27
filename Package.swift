// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "referral_ios_sdk",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "referral_ios_sdk",
            targets: ["referral_ios_sdk"]),
    ],
    targets: [
        .target(
            name: "referral_ios_sdk"),
        .testTarget(
            name: "referral_ios_sdkTests",
            dependencies: ["referral_ios_sdk"]),
    ]
)

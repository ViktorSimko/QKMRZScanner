// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
//  Package.swift
//  QKMRZParser
//
//  Created by Simkó Viktor on 2020. 09. 25..
//

import PackageDescription

let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "file:///Users/simkoviktor/nlv8/binx/iOS/BINXWithSubmodules/QKMRZParser", .branch("master")),
]

let libraryTarget = PackageDescription.Target.target(
    name: "QKMRZScanner",
    dependencies: ["QKMRZParser"],
    resources: [.copy("tessdata")]
)

let package = Package(
    name: "QKMRZScanner",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "QKMRZScanner",
            targets: ["QKMRZScanner"]
        ),
    ],
    targets: [libraryTarget]
)


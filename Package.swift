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
    .package(url: "https://github.com/ViktorSimko/QKMRZParser.git", .branch("master")),
    .package(url: "https://github.com/SwiftyTesseract/SwiftyTesseract.git", .branch("develop"))
]

let linkerSettings: [PackageDescription.LinkerSetting] = [
  .linkedLibrary("z"),
  .linkedLibrary("c++")
]

let libraryTarget = PackageDescription.Target.target(
    name: "QKMRZScanner",
    dependencies: ["QKMRZParser", "SwiftyTesseract"],
    resources: [.copy("Supporting Files/tessdata")],
    linkerSettings: linkerSettings
)

let package = Package(
    name: "QKMRZScanner",
    platforms: [.iOS(.v11), .macOS(.v10_13)],
    products: [
        .library(
            name: "QKMRZScanner",
            targets: ["QKMRZScanner"]
        )
    ],
    dependencies: dependencies,
    targets: [libraryTarget]
)


// swift-tools-version: 6.0

import PackageDescription

// アプリから切り出した、画面を持たない部分(DB・モデル・同期・単語情報の取得)。
// `swift test` だけで検証できるよう、UIKit / AppKit / SwiftUI には依存しない。
let package = Package(
  name: "EitangochoCore",
  platforms: [.iOS(.v18), .macOS(.v15)],
  products: [
    .library(name: "EitangochoData", targets: ["EitangochoData"]),
    .library(name: "EitangochoSync", targets: ["EitangochoSync"]),
  ],
  dependencies: [
    // 版は固定する。DB ファイルの扱いに関わるため、上げるときは変更点を読んでから上げる。
    .package(url: "https://github.com/groue/GRDB.swift.git", exact: "7.11.1")
  ],
  targets: [
    .target(
      name: "EitangochoData",
      dependencies: [.product(name: "GRDB", package: "GRDB.swift")]
    ),
    .target(
      name: "EitangochoSync",
      dependencies: ["EitangochoData", .product(name: "GRDB", package: "GRDB.swift")]
    ),
    .testTarget(
      name: "EitangochoDataTests",
      dependencies: ["EitangochoData"]
    ),
    .testTarget(
      name: "EitangochoSyncTests",
      dependencies: ["EitangochoSync"],
      resources: [.copy("Fixtures")]
    ),
  ]
)

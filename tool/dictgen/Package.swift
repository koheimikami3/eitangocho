// swift-tools-version: 6.0

import PackageDescription

// 事前生成辞書づくりの開発用ツール。アプリには含めない。
// 取得経路はアプリと同じもの(EitangochoWordInfo)をそのまま使い、
// 「今のアプリの自動入力で何が欠けるか」を正確に書き出す。
let package = Package(
  name: "dictgen",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(path: "../../native/Packages/EitangochoCore")
  ],
  targets: [
    .executableTarget(
      name: "dictgen-collect",
      dependencies: [
        .product(name: "EitangochoData", package: "EitangochoCore"),
        .product(name: "EitangochoWordInfo", package: "EitangochoCore"),
      ]
    )
  ]
)

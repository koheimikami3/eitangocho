import Foundation
import Testing

@testable import Eitangocho

/// Flutter 版の license_list_provider_test.dart を移したものと、同梱した本文が読めること。
struct LicenseCatalogTests {
  private static let mitText = """
    MIT License

    Copyright (c) 2020 Someone

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction.
    """

  private static let bsdText = """
    Copyright 2014 The Flutter Authors. All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    """

  // MARK: - detectLicenseName

  @Test func 主要なライセンスを本文から判別する() {
    #expect(LicenseCatalog.detectLicenseName(Self.mitText) == "MIT License")
    #expect(LicenseCatalog.detectLicenseName(Self.bsdText) == "BSD License")
    #expect(LicenseCatalog.detectLicenseName("Apache License\nVersion 2.0, January 2004") == "Apache License 2.0")
    #expect(LicenseCatalog.detectLicenseName("CC0 1.0 Universal") == "CC0 1.0 Universal")
    #expect(
      LicenseCatalog.detectLicenseName(
        "released under the Creative Commons Attribution-ShareAlike 4.0 International License") == "CC BY-SA 4.0")
  }

  @Test func 改行や連続空白をまたいでも判別できる() {
    #expect(LicenseCatalog.detectLicenseName("Permission is hereby granted,\n  free of charge") == "MIT License")
  }

  @Test func 判別できなければnil() {
    #expect(LicenseCatalog.detectLicenseName("独自ライセンスです。") == nil)
    #expect(LicenseCatalog.detectLicenseName("") == nil)
  }

  // MARK: - paragraphs

  @Test func 段落の中の改行は空白でつなぎ空行で段落を切る() {
    let text = "Copyright (c) 2004 SIL\nwith Reserved Font Names.\n\nThis Font Software is licensed\nunder the OFL.\n"
    #expect(
      LicenseCatalog.paragraphs(of: text) == [
        "Copyright (c) 2004 SIL with Reserved Font Names.", "This Font Software is licensed under the OFL.",
      ])
  }

  @Test func 前の行より字下げが深い行から新しい段落にする() {
    let text = "Conditions:\n  1. First item\n     continues here.\n  2. Second item\n"
    // 字下げの分の空白は段落に含めない。浅くなった行は前の段落に続く(Flutter 版と同じ)。
    #expect(
      LicenseCatalog.paragraphs(of: text) == [
        "Conditions:", "1. First item", "continues here. 2. Second item",
      ])
  }

  @Test func CRLFと改ページも段落の区切りとして扱う() {
    #expect(LicenseCatalog.paragraphs(of: "a\r\n\r\nb\u{0C}c") == ["a\r", "b", "c"])
  }

  @Test func 段落の中に残ったCRは空白にする() {
    let items = LicenseCatalog.group([LicenseEntry(packages: ["x"], text: "one\r\ntwo\r\n\r\nthree\r\n")])
    #expect(items.first?.texts == ["one  two\n\nthree"])
  }

  @Test func まとめるときは段落を空行で区切る() {
    let items = LicenseCatalog.group([LicenseEntry(packages: ["x"], text: "line one\nline two\n\nnext\n")])
    #expect(items.first?.texts == ["line one line two\n\nnext"])
  }

  // MARK: - group

  @Test func パッケージ単位にまとめ名前順に並べる() {
    let items = LicenseCatalog.group([
      LicenseEntry(packages: ["zebra"], text: Self.mitText),
      LicenseEntry(packages: ["alpha"], text: Self.bsdText),
    ])
    #expect(items.map(\.name) == ["alpha", "zebra"])
    #expect(items.first?.summary == "BSD License")
    #expect(items.last?.summary == "MIT License")
  }

  @Test func 一つのエントリが複数パッケージに紐づく場合は全部に配る() {
    let items = LicenseCatalog.group([LicenseEntry(packages: ["a", "b"], text: Self.mitText)])
    #expect(items.map(\.name) == ["a", "b"])
    #expect(items.allSatisfy { $0.summary == "MIT License" })
  }

  @Test func 同じパッケージの複数ライセンスは一行にまとめる() {
    let items = LicenseCatalog.group([
      LicenseEntry(packages: ["dual"], text: Self.mitText),
      LicenseEntry(packages: ["dual"], text: Self.bsdText),
    ])
    #expect(items.count == 1)
    #expect(items.first?.texts.count == 2)
    // 種別が割れるので nil(表示側が件数表記にする)
    #expect(items.first?.summary == nil)
  }

  @Test func 種別が判別できない単一ライセンスはsummaryがnilになる() {
    let items = LicenseCatalog.group([LicenseEntry(packages: ["x"], text: "独自ライセンス")])
    #expect(items.first?.summary == nil)
  }

  @Test func 本文が空のエントリは無視する() {
    let items = LicenseCatalog.group([
      LicenseEntry(packages: ["empty"], text: "   "),
      LicenseEntry(packages: ["ok"], text: Self.mitText),
    ])
    #expect(items.map(\.name) == ["ok"])
  }

  @Test func パッケージ名の大文字小文字は並び順に影響しない() {
    let items = LicenseCatalog.group([
      LicenseEntry(packages: ["Zebra"], text: Self.mitText),
      LicenseEntry(packages: ["alpha"], text: Self.mitText),
    ])
    #expect(items.map(\.name) == ["alpha", "Zebra"])
  }

  // MARK: - 同梱の一覧

  @Test func 出典とフォントとSwiftパッケージを同梱の本文から組める() throws {
    let items = try LicenseCatalog.load()
    #expect(
      items.map(\.name) == [
        "Andika", "EJDict-hand", "Firebase", "Google Translate", "GoogleAdsOnDeviceConversion",
        "GoogleAppMeasurement", "GoogleUtilities", "GRDB.swift", "Inter", "nanopb", "Noto Sans JP", "Noto Sans TC",
        "Promises", "Tatoeba", "Wiktionary / kaikki.org",
      ])
    let summaries = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.summary) })
    #expect(summaries["Inter"] == "SIL Open Font License 1.1")
    #expect(summaries["GRDB.swift"] == "MIT License")
    #expect(summaries["Firebase"] == "Apache License 2.0")
    #expect(summaries["Tatoeba"] == "CC BY 2.0 FR")
  }

  @Test func iOSだけのパッケージの本文も同梱されている() throws {
    // テストは macOS で動くので一覧には出ないが、本文は両 OS の成果物に入る(同じリソースのフォルダ)。
    let items = LicenseCatalog.group(
      try LicenseCatalog.iOSOnlyPackages.map { name, resource in
        let url = try #require(Bundle.main.url(forResource: resource, withExtension: "txt"))
        return LicenseEntry(packages: [name], text: try String(contentsOf: url, encoding: .utf8))
      })
    let summaries = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.summary) })
    #expect(
      summaries == [
        "GoogleMobileAds": "Apache License 2.0", "GoogleUserMessagingPlatform": "Apache License 2.0",
        "RevenueCat": "MIT License",
      ])
  }
}

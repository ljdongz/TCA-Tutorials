//
//  NumberFactClient.swift
//  TCA-Tutorials
//
//  Created by 이정동 on 3/31/25.
//

import Foundation
import ComposableArchitecture


protocol NumberFactClient: Sendable {
  var fetch: @Sendable (Int) async throws -> String { get set }
}

struct NumberFactClientImpl: NumberFactClient {
  var fetch: @Sendable (Int) async throws -> String = { number in
    let (data, _) = try await URLSession.shared
      .data(from: URL(string: "http://numbersapi.com/\(number)")!)
    return String(decoding: data, as: UTF8.self)
  }
}

struct StubNumberFactClient: NumberFactClient {
  var fetch: @Sendable (Int) async throws -> String = {
    return "Stub: \($0)"
  }
}

enum NumberFactClientKey: DependencyKey {
  static let liveValue: any NumberFactClient = NumberFactClientImpl()
}

extension DependencyValues {
  var numberFact: any NumberFactClient {
    get { self[NumberFactClientKey.self] }
    set { self[NumberFactClientKey.self] = newValue }
  }
}
